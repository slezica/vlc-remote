app.factory '$vlc', ($http, $base64, $interval, $rootScope) ->
  class Player
    constructor: ->
      @address   = null
      @connected = false

      @status =
        clip  : null
        player: null

      @scope = $rootScope.$new()

    on: (event, handler) ->
      @scope.$on event, (event, args...) ->
        handler(args...)

    request: (endpoint, params) ->
      $http.get(@address + '/requests/' + endpoint, { params })
      .then (res) =>
        return res.data

      .catch (err) =>
        @disconnect()

    command: (name, params) ->
      @request("status.json?command=#{name}", params).then @refresh.bind(@)

    refresh: ->
      @request('status.json').then (res) =>
        console.log @
        _.extend(@,
          clip:
            title : res.information?.category?.meta?.title
            artist: res.information?.category?.meta?.artist
            length: res.length

          state : res.state
          time  : res.time
          volume: res.volume

          fullscreen_on: res.fullscreen
          random_on    : res.random
          repeat_on    : res.repeat
          loop_on      : res.loop
        )

        @scope.$broadcast('change')
        return @


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

    connect: (address) ->
      @address = address
      @reconnect()

    reconnect: ->
      @disconnect()
      @refresh().then =>
        @connected = true
        @timer = $interval @refresh.bind(@), 1000

    disconnect: ->
      @connected = false;
      @timer.cancel() if @timer?
      delete @timer


  return new Player
