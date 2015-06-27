angular.module('narra.ui').factory 'p5Factory', ($injector) ->
  p5Wrapper =
    init: (sketch, node) ->
      @destroy()
      if sketch
        if $injector.has(sketch)
          sketch = $injector.get(sketch)
        @instance = new p5(sketch, node)
    destroy: ->
      if @instance
        @instance.remove()
        @instance = null
  ->
    Object.create p5Wrapper