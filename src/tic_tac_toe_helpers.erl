-module(tic_tac_toe_helpers).

-export([priv_dir_path/1]).

%% @private Return the path to the priv/ directory of an application.
-spec priv_dir_path(atom()) -> string().
priv_dir_path(App) ->
	case code:priv_dir(App) of
		{error, bad_name} -> priv_dir_mod(App);
		Dir -> Dir
	end.

priv_dir_mod(Mod) ->
    case code:which(Mod) of
        File when not is_list(File) -> "../priv";
        File -> filename:join([filename:dirname(File),"../priv"])
    end.

