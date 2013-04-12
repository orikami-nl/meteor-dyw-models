## dyw-models
Simple reactive models with validation

### Usage

```coffeescript
###
Define a model that uses Animals as its collection
###
 
class @Animal extends DYWModel
  @collection "Animals" # Ruby style macro
 
  @validate_presence ["name","sound"]
 
  # Class method
  @makeNoise: =>
    console.log _.map this.find().fetch(), (animal) ->
      animal.sound
 
  # Instance method
  makeNoise: ->
    console.log this.sound


# Insert documents in model
Animal.insert({name: "raptor", sound: "roar"})
Animal.insert({name: "dog", sound: "bark"})
 
Animal.findOne({name: "raptor"}).makeNoise() # prints "roar"
Animal.makeNoise() # prints ["roar","bark"]

```

### Todo
#### Tests!