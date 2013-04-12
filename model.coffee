class @DYWModel
  constructor: (doc) ->
    _.extend this, doc

  @collection: (collection_name) ->
    collection = new Meteor.Collection collection_name,
      transform: (doc) =>
        new this(doc)

    # Do validation on server
    collection.allow
      insert: (userId, doc) =>
        instance = new this(doc)
        instance.valid() and @authorize.insert(userId, doc)
      update: (userId, doc) =>
        instance = new this(doc)
        instance.valid() and @authorize.update(userId, doc)

    if @deny
      collection.deny @deny()

    _.extend this, collection

  # Set the required fields
  @validate_presence: (required_fields) ->
    if _.isString(required_fields)
      required_fields = [required_fields]
    @_required_fields = required_fields

  # Authorize by default
  @authorize:
    insert: (userId, doc) -> true
    update: (userId, doc) -> true
    remove: (userId, doc) -> true

  # Check if all required fields are given
  validate_presence: ->
    if @constructor._required_fields
      valid = true
      _.each @constructor._required_fields, (key) =>
        unless @fields()[key]
          valid = false
      return valid
    else
      true

  # Return the document without the model
  fields: ->
    fields = {}
    _.each _.keys(this), (key) =>
      unless key[0] == "_"
        fields[key] = this[key]
    return fields

  # Check all validators
  valid: ->
    @validate_presence()

  # Insert or update document if valid
  save: ->
    if @valid()
      if @_id
        @constructor.update {_id: @_id}, {$set: @fields()}
      else
        @_id = @constructor.insert @fields()
    else
      console.error "Validation failed."
