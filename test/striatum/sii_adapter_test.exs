defmodule Striatum.SIIAdapterTest do
  use ExUnit.Case

  alias Striatum.SIIAdapter.Mock

  describe "submit_dte/1" do
    test "accepts DTE with even amount" do
      result =
        Mock.submit_dte(%{
          monto: 1000,
          folio: 1,
          rut_emisor: "76000000-1",
          rut_receptor: "66666666-6",
          organization_id: nil
        })

      assert {:ok, result} = result
      assert result.folio == 1
      assert result.sii_track_id =~ "sii_track_"
    end

    test "rejects DTE with odd amount" do
      assert {:error, :rejected} =
               Mock.submit_dte(%{
                 monto: 1001,
                 folio: 1,
                 rut_emisor: "76000000-1",
                 rut_receptor: "66666666-6",
                 organization_id: nil
               })
    end

    test "timeout with amount divisible by 19" do
      assert {:error, :timeout} =
               Mock.submit_dte(%{
                 monto: 1900,
                 folio: 1,
                 rut_emisor: "76000000-1",
                 rut_receptor: "66666666-6",
                 organization_id: nil
               })
    end

    test "accepts large even amount" do
      result =
        Mock.submit_dte(%{
          monto: 1_000_000,
          folio: 142,
          rut_emisor: "76000000-1",
          rut_receptor: "11111111-1",
          organization_id: nil
        })

      assert {:ok, _} = result
    end
  end

  describe "check_certificate_expiry/1" do
    test "returns days until expiry" do
      assert {:ok, 365} = Mock.check_certificate_expiry(%{})
    end
  end

  describe "get_available_folios/1" do
    test "returns available and max folios" do
      assert {:ok, 500, 1000} = Mock.get_available_folios(%{})
    end
  end
end
