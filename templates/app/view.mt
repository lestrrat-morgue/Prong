? my ($req, $stash) = @_;
? $_mt->wrapper_file('wrapper.mt')->(sub {

<?= Text::MicroTemplate::encoded_string($stash->{content}->content) ?>

? });
