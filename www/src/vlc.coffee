app.factory '$vlc', ($http, $base64, $interval, $rootScope) ->
  class Player
    constructor: ->
      @address   = null
      @connected = false

      @status =
        clip  : null
        player: null

      @scope = $rootScope.$new()

    _set_status: (status) ->
      _.extend @,
        clip:
          title : status.information?.category?.meta?.title
          artist: status.information?.category?.meta?.artist
          length: status.length

        state : status.state
        time  : status.time
        volume: status.volume

        fullscreen_on: status.fullscreen
        random_on    : status.random
        repeat_on    : status.repeat
        loop_on      : status.loop

      @emit('change')

    on: (event, handler) ->
      @scope.$on event, (event, args...) ->
        handler(args...)

    emit: (event, data) ->
      @scope.$broadcast(event, data)

    request: (endpoint, params) ->
      $http.get(@address + '/requests/' + endpoint, { params })
      .then (res) =>
        return res.data

    command: (name, params) ->
      @request("status.json?command=#{name}", params).then @refresh.bind(@)

    refresh: ->
      @request('status.json')
        .then (res) =>
          @_set_status(res)
          return

        .catch (err) =>
          @disconnect()
          throw err

    connect: (address) ->
      @address = address

      @refresh().then =>
        @connected = true
        @timer = $interval @refresh.bind(@), 1000
        return # careful, @timer is a Promise

    reconnect: ->
      @connect(@address)

    disconnect: ->
      @connected = false
      $interval.cancel(@timer) if @timer?
      delete @timer
      @emit('disconnected')

    # Commands:
    play      : -> @command('pl_play')
    pause     : -> @toggle() if @state isnt 'paused'
    toggle    : -> @command('pl_pause')
    stop      : -> @command('pl_stop')
    next      : -> @command('pl_next')
    previous  : -> @command('pl_previous')
    random    : -> @command('pl_random')
    loop      : -> @command('pl_loop')
    repeat    : -> @command('pl_repeat')
    fullscreen: -> @command('fullscreen')

    seek: (val) ->
      @command('seek', { val })

    volume: (level) ->
      # level can be like '+3', '-3', '10' or '10%'
      @command('volume', { val: level })


  return new Player
