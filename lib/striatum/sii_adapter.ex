defmodule Striatum.SIIAdapter do
  @moduledoc """
  Behaviour for SII (Servicio de Impuestos Internos) DTE adapters.

  Implementations handle electronic invoice submission to Chile's tax authority.
  Supports both production (palena) and certification (maullido) environments.
  """

  @type dte_params :: %{
          rut_emisor: String.t(),
          rut_receptor: String.t(),
          monto: integer(),
          folio: integer(),
          tipo_dte: integer(),
          branch_code: String.t(),
          certificate_pem: String.t(),
          private_key_pem: String.t()
        }

  @type submit_result ::
          {:ok, %{folio: integer(), sii_track_id: String.t()}}
          | {:error, :rejected}
          | {:error, :timeout}
          | {:error, :invalid_credentials}

  @callback submit_dte(dte_params()) :: submit_result()
  @callback check_certificate_expiry(credentials :: map()) :: {:ok, integer()} | {:error, atom()}
  @callback get_available_folios(credentials :: map()) ::
              {:ok, integer(), integer()} | {:error, atom()}
end
