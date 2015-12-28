defmodule ElixirScript.Translator.Quote.Test do
  use ShouldI
  import ElixirScript.TestHelper

  test "quote number" do
    ex_ast = quote do
        quote do: 1
    end

    js_code = "1"

    assert_translation(ex_ast, js_code)
  end

  test "quote atom" do
    ex_ast = quote do
        quote do: :time
    end

    js_code = "Symbol.for('time')"

    assert_translation(ex_ast, js_code)
  end


  test "quote 2 element tuple" do
    ex_ast = quote do
        quote do: {1, 2}
    end

    js_code = "Elixir.Core.Functions.new_tuple(1, 2)"

    assert_translation(ex_ast, js_code)
  end


  test "quote 3 element tuple" do
    ex_ast = quote do
        quote do: {1, 2, 3}
    end

    js_code = "Elixir.Core.Functions.new_tuple(Symbol.for('{}'), Elixir.Core.List(), Elixir.Core.List(1, 2, 3))"

    assert_translation(ex_ast, js_code)
  end


  test "quote function call" do
    ex_ast = quote do
        quote do: test(1)
    end

    js_code = "Elixir.Core.Functions.new_tuple(Symbol.for('test'),
      Elixir.Core.List(Elixir.Core.Functions.new_tuple(Symbol.for('context'),Symbol.for('Elixir.ElixirScript.Translator.Quote.Test')),Elixir.Core.Functions.new_tuple(Symbol.for('import'),Symbol.for('Elixir.ExUnit.Case'))),
      Elixir.Core.List(1))"

    assert_translation(ex_ast, js_code)
  end


  test "quote function with variable" do
    ex_ast = quote do
        quote do: test(x)
    end

    js_code = "Elixir.Core.Functions.new_tuple(
      Symbol.for('test'),
      Elixir.Core.List(Elixir.Core.Functions.new_tuple(Symbol.for('context'),Symbol.for('Elixir.ElixirScript.Translator.Quote.Test')),Elixir.Core.Functions.new_tuple(Symbol.for('import'),Symbol.for('Elixir.ExUnit.Case'))),
      Elixir.Core.List(Elixir.Core.Functions.new_tuple(Symbol.for('x'),Elixir.Core.List(),Symbol.for('Elixir.ElixirScript.Translator.Quote.Test')))
    )"

    assert_translation(ex_ast, js_code)
  end


  test "quote function call with unquote" do
    ex_ast = quote do
        quote do: test(unquote(x))
    end

    js_code = "Elixir.Core.Functions.new_tuple(
      Symbol.for('test'),
      Elixir.Core.List(Elixir.Core.Functions.new_tuple(Symbol.for('context'),Symbol.for('Elixir.ElixirScript.Translator.Quote.Test')),Elixir.Core.Functions.new_tuple(Symbol.for('import'),Symbol.for('Elixir.ExUnit.Case'))),
      Elixir.Core.List(x)
    )"

    assert_translation(ex_ast, js_code)
  end


  test "quote function call with unquote_slicing" do
    ex_ast = quote do
        quote do: sum(1, unquote_splicing(values), 5)
    end

    js_code = "Elixir.Core.Functions.new_tuple(Symbol.for('sum'), Elixir.Core.List(), Elixir.Enum.concat(Elixir.Core.List(1), values, Elixir.Core.List(5)))"

    assert_translation(ex_ast, js_code)
  end

  test "bind_quoted" do
    ex_ast = quote do
      quote bind_quoted: [x: x] do
        x * x
      end
    end

    js_code = "Elixir.Core.Functions.new_tuple(
      Symbol.for('*'),
      Elixir.Core.List(Elixir.Core.Functions.new_tuple(Symbol.for('context'),Symbol.for('Elixir.ElixirScript.Translator.Quote.Test')),Elixir.Core.Functions.new_tuple(Symbol.for('import'),Symbol.for('Elixir.ElixirScript.Kernel'))),
      Elixir.Core.List(x, x)
    )"

    assert_translation(ex_ast, js_code)
  end
end
