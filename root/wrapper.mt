? my ($content, %args) = @_;
<html>
<head>
    <title>Test</title>
? if ($args{scripts}) {
?   foreach my $script (@{ $args{scripts} }) {
?       if (ref $script ne 'HASH') {
?           $script = { uri => $script };
?       }
?       my $type = $script->{type} || 'text/javascript';
?       my $uri  = $script->{uri};
    <script type="<?= $type ?>" src="<?= $uri ?>"></script>
?   }
? }
</head>
<body>
<?= $content ?>
</body>
</html>