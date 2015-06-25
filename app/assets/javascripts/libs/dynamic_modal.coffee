class @DynamicModal

  # Options are :
  # error: Type function(response)
  # success: Type function(response)
  # open: Type function()
  # close: Type function()
  @setup: (scope, options) ->
    new DynamicModal(scope, options)

  constructor: (@container, @options) ->
    self = @
    @container.find('[data-toggle=dynamic-modal]').on "click", (e) ->
      e.preventDefault()
      el = $(@)
      modal = if el.data("target") then $(el.data("target")) else $("#dynamic-modal")
      cssClasses = el.data("class")
      $.get el.attr('href'), (response) =>
        modal.find('[data-role=modal-content]').html(response = $(response))
        window.App.setup(response)
        modal.modal('show')
        modal.find(".modal-dialog").addClass(cssClasses)
        modal.on "hidden.bs.modal", ->
          $(@).find(".modal-dialog").removeClass(cssClasses)
          if self.options?["close"]?
            self.options["close"].call(modal)

        if self.options?["open"]?
          self.options["open"].call(modal, response)


      modal.off("ajax:error").on "ajax:error", (request, response) ->
        modalContent = $(@).find('[data-role=modal-content]').html(response = $(response.responseText))
        window.App.setup(response)
        if self.options?["error"]?
          self.options["error"].call(modal, response)

      modal.off("ajax:success").on "ajax:success", (request, response) ->
        console.log(response.redirect)
        if self.options?["success"]?
          self.options["success"].call(modal, response)
        else if response.redirect
          window.location = response.redirect
          if response.redirect.indexOf("#") != -1
            window.location.reload(true)