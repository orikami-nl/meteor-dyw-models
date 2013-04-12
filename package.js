Package.describe({
  summary: "Simple collection models with validation"
});

Package.on_use(function (api) {
  var both = ['client', 'server'];
  api.use(['underscore','coffeescript'], both);


  api.add_files('model.coffee', both);
});

