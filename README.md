NAME
====

Data::Crumbr - Render data structures for easy searching and parsing

SYNOPSYS
========

    use Data::Crumbr;

    say crumbr(\%options)->($data_structure);


    $ cat sample.json
    {
        "ciao": [
            "a",
            [],
            "tutti",
            {
                "quanti": "voi",
                "hey ☺": {},
                "some": 123.123
            }
        ]
    }

    $ crumbr sample.json
    {"ciao"}[0]:"a"
    {"ciao"}[1]:[]
    {"ciao"}[2]:"tutti"
    {"ciao"}[3]{"hey ☺"}:{}
    {"ciao"}[3]{"quanti"}:"voi"
    {"ciao"}[3]{"some"}:123.123

    $ crumbr --style uri sample.json
    /ciao/0 "a"
    /ciao/1 []
    /ciao/2 "tutti"
    /ciao/3/hey%20%E2%98%BA {}
    /ciao/3/quanti "voi"
    /ciao/3/some 123.123


ALL THE REST
============

Want to know more? [See the module's documentation](http://search.cpan.org/perldoc?App::Crumbr) to figure out
all the bells and whistles of this module!

Want to install the latest release? [Go fetch it on CPAN](http://search.cpan.org/dist/App::Crumbr/).

Want to contribute? [Fork it on GitHub](https://github.com/polettix/App::Crumbr).

That's all folks!

