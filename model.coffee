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
        instance.valid() and @_authorize().insert(userId, doc)
      update: (userId, doc) =>
        instance = new this(doc)
        instance.valid() and @_authorize().update(userId, doc)
      remove: (userId, doc) =>
        instance = new this(doc)
        @_authorize().remove(userId, doc)

    collection.deny
      insert: (userId, doc) =>
        instance = new this(doc)
        @_unauthorize().insert(userId, doc)
      update: (userId, doc) =>
        instance = new this(doc)
        @_unauthorize().update(userId, doc)
      remove: (userId, doc) =>
        instance = new this(doc)
        @_unauthorize().remove(userId, doc)

    _.extend this, collection

  @_authorize: ->
    defaults = 
      insert: (userId, doc) -> true
      update: (userId, doc) -> true
      remove: (userId, doc) -> true
    if @authorize
      _.extend defaults, @authorize
    else
      defaults

  @_unauthorize: ->
    defaults = 
      insert: (userId, doc) -> false
      update: (userId, doc) -> false
      remove: (userId, doc) -> false
    if @unauthorize
      _.extend defaults, @unauthorize
    else
      defaults

  # Set the required fields
  @validate_presence: (required_fields) ->
    if _.isString(required_fields)
      required_fields = [required_fields]
    @_required_fields = required_fields

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

  # Is model persisted in database?
  isPersisted: ->
    if @_id then true else false

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

  # Remov document from database
  remove: ->
    if @isPersisted
      @constructor.remove({_id: @_id})

