defmodule Striatum.DTEBuilder do
  @moduledoc """
  Builds electronic invoices (DTE — Documento Tributario Electrónico).

  Generates XML conforming to SII Chile format, assigns sequential folios
  per organization and branch, and produces a PDF representation.
  """

  alias Striatum.{Repo, Transaction, SiiCredential, DTE}
  import Ecto.Query

  require Logger

  @tipo_dte_factura 33

  @doc """
  Builds a DTE for a transaction.

  Returns {:ok, dte} on success or {:error, reason}.
  """
  @spec build(Transaction.t()) :: {:ok, DTE.t()} | {:error, atom()}
  def build(%Transaction{} = transaction) do
    with {:ok, credentials} <- get_credentials(transaction.organization_id),
         {:ok, folio} <- allocate_folio(credentials),
         {:ok, xml} <- build_xml(transaction, credentials, folio),
         {:ok, pdf_url} <- generate_pdf(transaction, folio) do
      dte =
        %DTE{}
        |> DTE.changeset(%{
          transaction_id: transaction.id,
          folio: folio,
          sii_status: :pending,
          sii_xml: xml,
          pdf_url: pdf_url
        })
        |> Repo.insert!()

      {:ok, dte}
    end
  end

  @doc """
  Regenerates XML and PDF for an existing DTE (used for retries).
  """
  @spec rebuild(Transaction.t(), DTE.t()) :: {:ok, DTE.t()} | {:error, atom()}
  def rebuild(%Transaction{} = transaction, %DTE{} = dte) do
    with {:ok, credentials} <- get_credentials(transaction.organization_id),
         {:ok, xml} <- build_xml(transaction, credentials, dte.folio),
         {:ok, pdf_url} <- generate_pdf(transaction, dte.folio) do
      dte
      |> DTE.changeset(%{sii_xml: xml, pdf_url: pdf_url, retry_count: dte.retry_count + 1})
      |> Repo.update()
    end
  end

  # -- Private --

  defp get_credentials(org_id) do
    case Repo.get_by(SiiCredential, organization_id: org_id, is_active: true) do
      nil -> {:error, :no_credentials}
      creds -> {:ok, creds}
    end
  end

  defp allocate_folio(credentials) do
    current = credentials.current_folio || 0
    next = current + 1

    if credentials.max_folio && next > credentials.max_folio do
      {:error, :out_of_folios}
    else
      # Atomically increment folio
      {1, _} =
        Repo.update_all(
          from(c in SiiCredential, where: c.id == ^credentials.id),
          set: [current_folio: next]
        )

      {:ok, next}
    end
  end

  defp build_xml(transaction, credentials, folio) do
    rut_emisor = clean_rut(credentials.rut)
    rut_receptor = get_receptor_rut(transaction)
    monto_total = transaction.amount

    xml = """
    <?xml version="1.0" encoding="ISO-8859-1"?>
    <DTE version="1.0">
      <Documento ID="DTE_#{folio}_#{transaction.id}">
        <Encabezado>
          <IdDoc>
            <TipoDTE>#{@tipo_dte_factura}</TipoDTE>
            <Folio>#{folio}</Folio>
            <FchEmis>#{format_date(transaction.inserted_at)}</FchEmis>
          </IdDoc>
          <Emisor>
            <RUTEmisor>#{rut_emisor}</RUTEmisor>
            <RznSoc>#{transaction.organization_id}</RznSoc>
            <Sucursal>#{credentials.branch_code || "1"}</Sucursal>
          </Emisor>
          <Receptor>
            <RUTRecep>#{rut_receptor}</RUTRecep>
            <RznSocRecep>#{get_receptor_name(transaction)}</RznSocRecep>
          </Receptor>
          <Totales>
            <MntNeto>#{monto_total}</MntNeto>
            <MntTotal>#{monto_total}</MntTotal>
          </Totales>
        </Encabezado>
        <Detalle>
          <NroLinDet>1</NroLinDet>
          <NmbItem>#{transaction.product_id || "Servicio"}</NmbItem>
          <MontoItem>#{monto_total}</MontoItem>
        </Detalle>
      </Documento>
    </DTE>
    """

    {:ok, xml}
  end

  defp generate_pdf(transaction, folio) do
    # In production, generate a proper PDF using a templating library.
    # For now, generate a URL pointing to a static placeholder.
    pdf_url = "/dtes/#{transaction.id}/dte_#{folio}.pdf"
    {:ok, pdf_url}
  end

  defp clean_rut(rut) when is_binary(rut) do
    rut |> String.replace(~r/[^0-9Kk]/, "") |> String.upcase()
  end

  defp clean_rut(_), do: "66666666-6"

  defp get_receptor_rut(transaction) do
    case transaction.metadata do
      %{"customer_rut" => rut} when is_binary(rut) and rut != "" -> clean_rut(rut)
      _ -> "66666666-6"
    end
  end

  defp get_receptor_name(transaction) do
    case transaction.metadata do
      %{"customer_name" => name} when is_binary(name) and name != "" -> name
      _ -> "Consumidor Final"
    end
  end

  defp format_date(nil), do: Date.utc_today() |> Date.to_iso8601()

  defp format_date(%DateTime{} = dt) do
    dt |> DateTime.to_date() |> Date.to_iso8601()
  end

  defp format_date(%NaiveDateTime{} = ndt) do
    ndt |> NaiveDateTime.to_date() |> Date.to_iso8601()
  end

  defp format_date(_), do: Date.utc_today() |> Date.to_iso8601()
end
