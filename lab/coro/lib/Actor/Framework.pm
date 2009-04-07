package Actor::Framework;
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    as_is => ['run'],
);

sub run {
    EV::loop();
}
