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

#vscode plugin
https://github.com/elixir-lsp/vscode-elixir-ls

#generate Accounts context
mix phx.gen.html Accounts User users email:string:unique name:string:unique password:string
mix ecto.migrate
mix ecto.rollback
$ psql athasha_dev

IO.inspect(params)
```