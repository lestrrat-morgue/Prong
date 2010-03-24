? my ($req, $stash) = @_;
? $_mt->wrapper_file('wrapper.mt')->(sub {

? foreach my $module (@{ $stash->{modules} }) {
<a href="/app/<?= $module->id ?>"><?= $module->title ?></a>
? }

? });