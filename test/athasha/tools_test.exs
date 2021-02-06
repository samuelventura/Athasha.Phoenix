defmodule Athasha.Auth.ToolsTest do
  use Athasha.DataCase

  alias Athasha.Auth.Tools

  describe "password encrypt" do
    test "leaves blank strings as blank" do
      assert "" == Tools.encrypt_ifn_blank(" ")
      assert "" == Tools.encrypt_ifn_blank("\n")
      assert "" == Tools.encrypt_ifn_blank("\r")
      assert "" == Tools.encrypt_ifn_blank("\t")
    end

    test "encodes non blank strings" do
      assert Tools.encrypt("abc") == Tools.encrypt_ifn_blank("abc")
      assert 64 == String.length(String.trim(Tools.encrypt("abc")))
    end
  end

  describe "email validator" do
    test "accepts know valid formats" do
      assert true == Tools.valid_email?("a@b.com")
      assert true == Tools.valid_email?("a@ip")
    end

    test "rejects double, none or misplaced @" do
      assert false == Tools.valid_email?("a@@b.com")
      assert false == Tools.valid_email?("a@b@.com")
      assert false == Tools.valid_email?("@a.b.com")
      assert false == Tools.valid_email?("a.b.com@")
    end

    test "rejects white spaces" do
      assert false == Tools.valid_email?(" a@b.com")
      assert false == Tools.valid_email?("a@b.com ")
      assert false == Tools.valid_email?("a@b com")
    end
  end
end
