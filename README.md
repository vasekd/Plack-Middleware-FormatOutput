# NAME

Plack::Middleware::FormatOutput - Format output struct by Accept header.

# SYNOPSIS

        use Plack::Middleware::FormatOutput;

        builder {
                enable 'FormatOutput';
                mount "/api" => sub { return {'link' => 'content'} };
        };

# DESCRIPTION

The Middleware formats output perl struct by "Accept" header param or by format param in URL.

You can get json when define:

- Accept header application/json

    or

- Add ?format=application/json to URL

For complete RestAPI in Perl use: 

- Plack::Middleware::RestAPI
- Plack::Middleware::ParseContent

# CONSTANTS

## DEFAULT MIME TYPES

- application/json
- text/yaml
- text/plain
- text/html - it uses Rest::HtmlVis as default formater if installed

# PARAMETERS

## mime\_type

Specify if and how returned content should be formated in browser.

For example:

        use Plack::Middleware::FormatOutput;
        use My::HTML

        builder {
                enable 'FormatOutput', mime_type => {
                        'text/html' => sub{ My::HTML::Parse(@_) }
                };
                mount "/api" => sub { return {'link' => 'content'} };
        };

## htmlvis (if Rest::HtmlVis is installed)

Define parameters for Rest::HtmlVis. 

For example:

        use Plack::Middleware::FormatOutput;

        builder {
                enable 'FormatOutput', htmlvis => {
                        links => 'My::Links'
                };
                mount "/api" => sub { return {'links' => 'content'} };
        };

# TUTORIAL

[http://psgirestapi.dovrtel.cz/](http://psgirestapi.dovrtel.cz/)

# AUTHOR

Václav Dovrtěl <vaclav.dovrtel@gmail.com>

# BUGS

Please report any bugs or feature requests to github repository.

# ACKNOWLEDGEMENTS

Inspired by [https://github.com/towhans/hochschober](https://github.com/towhans/hochschober)

# REPOSITORY

[https://github.com/vasekd/Plack-Middleware-FormatOutput](https://github.com/vasekd/Plack-Middleware-FormatOutput)

# COPYRIGHT

Copyright 2015- Václav Dovrtěl

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
