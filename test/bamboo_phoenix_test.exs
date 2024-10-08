defmodule Bamboo.PhoenixTest do
  use ExUnit.Case

  defmodule PhoenixLayouts do
    use Phoenix.Component

    embed_templates "support/templates/phoenix_layout/*.html", suffix: "_html"
    embed_templates "support/templates/phoenix_layout/*.text", suffix: "_text"
  end

  defmodule EmailHTML do
    use Phoenix.Component

    embed_templates "support/templates/email/*.html", suffix: "_html"
    embed_templates "support/templates/email/*.text", suffix: "_text"

    def function_in_view do
      "function used in Bamboo.TemplateTest but needed because template is compiled"
    end
  end

  defmodule Email do
    use Bamboo.Phoenix, component: EmailHTML

    def text_and_html_email_with_layout do
      new_email()
      |> put_layout({PhoenixLayouts, :app})
      |> render(:text_and_html_email)
    end

    def text_email_with_layout do
      new_email()
      |> put_text_layout({PhoenixLayouts, "app_text"})
      |> render("text_email_text")
    end

    def html_email_with_layout do
      new_email()
      |> put_html_layout({PhoenixLayouts, "app_html"})
      |> render("html_email_html")
    end

    def text_and_html_email do
      new_email()
      |> render(:text_and_html_email)
    end

    def email_with_assigns(user) do
      new_email()
      |> render(:email_with_assigns, user: user)
    end

    def email_with_already_assigned_user(user) do
      new_email()
      |> assign(:user, user)
      |> render(:email_with_assigns)
    end

    def html_email do
      new_email()
      |> render("html_email_html")
    end

    def text_email do
      new_email()
      |> render("text_email_text")
    end

    def no_template do
      new_email()
      |> render(:non_existent)
    end

    def invalid_template do
      new_email()
      |> render("template_foobar")
    end
  end

  test "render/2 allows setting a custom layout" do
    email = Email.text_and_html_email_with_layout()

    assert email.html_body =~ "HTML layout"
    assert email.html_body =~ "HTML body"
    assert email.text_body =~ "TEXT layout"
    assert email.text_body =~ "TEXT body"
  end

  test "render/2 allows setting a custom layout only for html" do
    email = Email.html_email_with_layout()

    assert email.html_body =~ "HTML layout"
    assert email.html_body =~ "HTML body"
  end

  test "render/2 allows setting a custom layout only for text" do
    email = Email.text_email_with_layout()

    assert email.text_body =~ "TEXT layout"
    assert email.text_body =~ "TEXT body"
  end

  test "render/2 renders html and text emails" do
    email = Email.text_and_html_email()

    assert email.html_body =~ "HTML body"
    assert email.text_body =~ "TEXT body"
  end

  test "render/2 renders html and text emails with assigns" do
    name = "Paul"
    email = Email.email_with_assigns(%{name: name})
    assert email.html_body =~ "<strong>#{name}</strong>"
    assert email.text_body =~ name

    name = "Paul"
    email = Email.email_with_already_assigned_user(%{name: name})
    assert email.html_body =~ "<strong>#{name}</strong>"
    assert email.text_body =~ name
  end

  test "render/2 renders html body if template extension is .html" do
    email = Email.html_email()

    assert email.html_body =~ "HTML body"
    assert email.text_body == nil
  end

  test "render/2 renders text body if template extension is .text" do
    email = Email.text_email()

    assert email.html_body == nil
    assert email.text_body =~ "TEXT body"
  end

  test "render/2 raises if template doesn't exist" do
    assert_raise ArgumentError, fn ->
      Email.no_template()
    end
  end

  test "render/2 raises if you pass an invalid template extension" do
    assert_raise ArgumentError, ~r/must end in either ".html" or ".text"/, fn ->
      Email.invalid_template()
    end
  end

  test "render raises if called directly" do
    assert_raise RuntimeError, ~r/documentation only/, fn ->
      Bamboo.Phoenix.render(:foo, :foo, :foo)
    end
  end
end
