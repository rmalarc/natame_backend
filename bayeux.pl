#!/usr/bin/perl
    use POE qw(Component::Client::Bayeux);
 
    POE::Component::Client::Bayeux->spawn(
        Host => '127.0.0.1',
        Alias => 'comet',
    );
 
    POE::Session->create(
        inline_states => {
            _start => sub {
                my ($kernel, $heap) = @_[KERNEL, HEAP];
                $kernel->alias_set('my_client');
 
                $kernel->post('comet', 'init');
                $kernel->post('comet', 'subscribe', '/chat/demo', 'events');
                $kernel->post('comet', 'publish', '/chat/demo', {
                    user => "POE",
                    chat => "POE has joined",
                    join => JSON::XS::true,
                });
            },
            events => sub {
                my ($kernel, $heap, $message) = @_[KERNEL, HEAP, ARG0];
 
                print STDERR "Client got subscribed message:\n" . Dumper($message);
            },
        },
    );
 
    $poe_kernel->run();
