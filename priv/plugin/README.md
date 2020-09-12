plugin
=====

A rebar plugin

Build
-----

    $ rebar3 compile

Use
---

Add the plugin to your rebar config:

    {plugins, [
        {plugin, {git, "https://host/user/plugin.git", {tag, "0.1.0"}}}
    ]}.

Then just call your plugin directly in an existing application:


    $ rebar3 plugin
    ===> Fetching plugin
    ===> Compiling plugin
    <Plugin Output>
