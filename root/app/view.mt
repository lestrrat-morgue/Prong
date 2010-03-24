? my ($req, $stash) = @_;
? $_mt->wrapper_file('wrapper.mt', 
?   scripts => [
?       "/static/js/gadgets.js"
?   ]
? )->(sub {

<?= Text::MicroTemplate::encoded_string($stash->{content}->content) ?>

? });
