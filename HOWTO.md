# Dev Environ

```bash
mbp2:samuel$ elixir --version
Erlang/OTP 23 [erts-11.1.7] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe] [dtrace]
Elixir 1.11.3 (compiled with Erlang/OTP 23)

mbp2:samuel$ mix --version
Erlang/OTP 23 [erts-11.1.7] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe] [dtrace]

Mix 1.11.3 (compiled with Erlang/OTP 23)

mbp2:samuel$ mix local.hex
* creating /Users/samuel/.mix/archives/hex-0.21.1

mbp2:samuel$ mix archive.install hex phx_new
* creating /Users/samuel/.mix/archives/phx_new-1.5.7

mbp2:samuel$ node --version
v15.4.0

mbp2:samuel$ npm --version
7.0.15

mbp2:samuel$ brew install postgres
mbp2:samuel$ brew services start postgresql
mbp2:samuel$ psql postgres
psql (13.1)
Type "help" for help.
```

# App Setup

```bash
git clone git@github.com:samuelventura/Athasha.Phoenix.git
cd Athasha.Phoenix
mix phx.new . --app athasha --live
mix ecto.create
#change port 8888 at dev.exs
mix phx.server
iex -S mix phx.server

#after cloning in different machine
mix deps.get
mix ecto.create
cd assets; npm install; cd ..
mix phx.server
#in Windows its asks to run it in admin cmd at least once to enable symlinks

#vscode plugin (deletes content on compilation failure, still valuable)
https://github.com/elixir-lsp/vscode-elixir-ls

#generate Auth context
mix phx.gen.html Auth User users email:string:unique name:string:unique password:string
mix ecto.drop; mix ecto.create
mix ecto.rollback; mix ecto.migrate
$ psql athasha_dev

IO.inspect(params)

mix test
mix test test/athasha_web/controllers/
mix test test/athasha_web/controllers/user_controller_test.exs
mix test test/athasha_web/controllers/user_controller_test.exs:<line_number>

mix test --trace 

MIX_ENV=test mix ecto.drop
MIX_ENV=test mix ecto.create
MIX_ENV=test mix ecto.migrate

mix ecto.gen.migration tree_schema

#backup following .gitignore specs
rsync -av --filter=':- .gitignore' Athasha.Phoenix test.yeico.com:

@session_id vs assigns[:session_id]

"files.associations": {
    "*.html.leex": "html-eex"
}
```
