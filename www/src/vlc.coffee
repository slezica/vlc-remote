app.factory '$vlc', ($http, $interval, $q, $rootScope) ->
  class Player
    constructor: ->
      @connection =
        status: 'disconnected'

      @scope = $rootScope.$new()

    setStatus: (status) ->
      @player =
        clip:
          title : status.information?.category?.meta?.title
          artist: status.information?.category?.meta?.artist
          length: status.length

        status: status.state
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
      $http.get(@connection.address + '/requests/' + endpoint, { params })
      .then (res) ->
        return res.data

      .catch (err) ->
        throw 'HTTP Error: ' + JSON.stringify(err, null, 2)

    command: (name, params) ->
      if not @connection.status is 'connected'
        throw new Error("Not connected to VLC")

      @request("status.json?command=#{name}", params) #.then => @ping()

    connect: (address) ->
      switch @connection.status
        when 'connected'
          $q.resolve(@connection)

        when 'connecting'
          if address is @connection.address
            @connection.promise
          else
            @disconnect()
            @connect(address)

        when 'disconnected'
          df = $q.defer()

          @connection =
            status : 'connecting'
            address: address
            timer  : null
            promise: df.promise

          attempt = =>
            console.log("VLC attempting connection to #{address}")

            @request('status.json').then (status) =>
              $interval.cancel(@connection.timer)

              @connection =
                status : 'connected'
                address: address
                timer  : $interval(@ping.bind(@), 1000)

              @setStatus(status)

              console.log("VLC connected to #{address}")
              df.resolve(@connection)
              @emit('connected')

          attempt()
          @connection.timer = $interval(attempt, 1000)
          return df.promise

    disconnect: ->
      return if @connection.status is 'disconnected'

      $interval.cancel(@connection.timer)
      @connection = { status: 'disconnected' }
      console.log("VLC disconnected")
      @emit('disconnected')

    ping: ->
      @request('status.json')
        .then @setStatus.bind(@)
        .catch (err) =>
          @disconnect()
          throw err

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


  return window.vlc = new Player
