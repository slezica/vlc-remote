window.app = angular.module('vlc-remote', ['ionic', 'base64'])


window.set = (object, attr) ->
  (value) ->
    object[attr] = value
    return value

window.get = (attr) ->
  (object) -> object[attr]

window.log = (message, extras...) ->
  console.log(message, extras...)
  return message


app.run ($ionicPlatform) ->
  $ionicPlatform.ready ->
    if(window.cordova && window.cordova.plugins.Keyboard)
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)

    if window.StatusBar
      StatusBar.styleDefault()


app.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider
    .state 'state',
      url        : '/'
      templateUrl: 'src/view.html'
      controller : 'appCtrl'

  $urlRouterProvider.otherwise('/')


app.controller 'appCtrl', ($scope, $base64, vlc) ->
  $scope.player = player = vlc.connect
    address : 'localhost:8100/api'
    username: ''
    password: '1'
