%%
%% MessagePack for Erlang
%%
%% Copyright (C) 2009-2013 UENISHI Kota
%%
%%    Licensed under the Apache License, Version 2.0 (the "License");
%%    you may not use this file except in compliance with the License.
%%    You may obtain a copy of the License at
%%
%%        http://www.apache.org/licenses/LICENSE-2.0
%%
%%    Unless required by applicable law or agreed to in writing, software
%%    distributed under the License is distributed on an "AS IS" BASIS,
%%    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%    See the License for the specific language governing permissions and
%%    limitations under the License.
%%
-module(msgpack_term).

-export([to_binary/1, from_binary/1,
         pack_ext/2, unpack_ext/2]).
-behabiour(msgpack_ext).

-define(ERLANG_TERM, 131).
-define(TERM_OPTION, [{enable_str,true},{ext,?MODULE},{allow_atom,none}]).

to_binary(Term) ->
    msgpack:pack(Term, ?TERM_OPTION).

from_binary(Bin) ->
    {ok, Term} = msgpack:unpack(Bin, ?TERM_OPTION),
    Term.

-spec pack_ext(tuple(), msgpack:options()) ->
                      {ok, {Type::byte(), Data::binary()}} |
                      {error, any()}.
pack_ext(Term, _Options) ->
    {ok, {?ERLANG_TERM, erlang:term_to_binary(Term)}}.

-spec unpack_ext(Type::byte(), Data::binary()) ->
    {ok, any()} | {error, any()}.
unpack_ext(?ERLANG_TERM, Bin) ->
    {ok, erlang:binary_to_term(Bin)}.

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

test_data() ->
    ['foobar atom', %% is_atom/1
     fun() -> ok end, %% is_function/1
     self(), %% is_pid/1
     %% is_port/1
     make_ref(), %% is_reference/1
     {me, foo, bar}, %% is_tuple/1
     {}].

t2b_b2t_test() ->
    Data = test_data(),
    ?assertEqual(Data,
                 msgpack:binary_to_term(msgpack:term_to_binary(Data))).

-endif.
