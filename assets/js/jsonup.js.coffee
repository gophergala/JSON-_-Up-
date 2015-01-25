# Boilerplate code borrowed from the internet to make react nice to use.
build_tag = (tag) ->
  (options...) ->
    options.unshift {} unless typeof options[0] is 'object'
    React.DOM[tag].apply @, options

DOM = (->
  object = {}
  for element in Object.keys(React.DOM)
    object[element] = build_tag element
  object
)()

{div, embed, ul, svg, li, label, select, option, br, p, a, img, textarea, table, tbody, thead, th, tr, td, form, h1, h2, h3, h4, input, span} = DOM
# End Boilerplate

JSONUp = React.createClass
  render: ->
    div {id: 'wrap'},
      div {id: 'header'},
        h1 {}, 'JSON ➔ Up?'
      div {id: 'demobox'}, DemoBox() # Box that shows how to post in ruby, curl etc
      div {id: 'upboxes'}, UpBoxes(ups: @props.ups) # the status and sparklines
      PhoneForm() if @props.ups && @props.ups.length > 0

# This will be the box that demos the post functionality
PostBox = React.createClass
  getInitialState: ->
    {
      demoName: 'server1.redis',
      demoStatus: 'UP',
      demoValue: ""+Math.floor((Math.random() * 99) + 1)
    }

  onSubmit: (e) ->
    e.preventDefault()
    http = new XMLHttpRequest()
    http.open("POST", "/push/#{UserID}", true);
    http.send(JSON.stringify([{
      name: @state.demoName,
      status: @state.demoStatus,
      value: @state.demoValue
    }]))

  setName: (e) -> @setState({demoName: e.target.value})

  setStatus: (e) -> @setState({demoStatus: e.target.value})

  setValue: (e) -> @setState({demoValue: e.target.value})

  render: ->
    form {id: 'postform', onSubmit: @onSubmit},
      div {className: 'demoform'},
        span {}, '[{'
        br {}
        span {}, '"name":"'
        input {value: @state.demoName, onChange: @setName}
        span {}, '",'
        br {}
        span {}, '"status":"'
        input {value: @state.demoStatus, className: 'sm', onChange: @setStatus}
        span {}, '",'
        br {}
        span {}, '"value":"'
        input {value: @state.demoValue, className: 'sm', onChange: @setValue}
        span {}, '"'
        br {}
        span {}, '}]'

      div {className: 'submit-div'},
        div {}, "Your user id is #{UserID}"
        input {type: 'submit', className: 'submitbutton', value: "POST to https://api.jsonup.com/push/#{UserID}"}

DemoBox = React.createClass

  getInitialState: ->
    {selected: 'menu-livedemo'}

  handleClick: (e) ->
    e.preventDefault()
    @state.selected = e.target.id
    render()

  classNameFor: (menuname) ->
    if @state.selected == "menu-" + menuname
      "selected"
    else
      ""

  render: ->
    div {id: 'menu-wrap'},
      ul {id: 'menu'},
        li {},
          a {href: '#', id: 'menu-livedemo', onClick: @handleClick, className: @classNameFor('livedemo')}, 'Live Demo'
        li {},
          a {href: '#', id: 'menu-ruby', onClick: @handleClick, className: @classNameFor('ruby')}, 'Ruby'
        li {},
          a {href: '#', id: 'menu-go', onClick: @handleClick, className: @classNameFor('go')}, 'Go'
        li {},
          a {href: '#', id: 'menu-javascript', onClick: @handleClick, className: @classNameFor('javascript')}, 'Javascript'

      div {className: 'menu-content'}, PostBox() if @state.selected == 'menu-livedemo'
      div {className: 'menu-content'}, 'Todo: go example' if @state.selected == 'menu-go'
      div {className: 'menu-content'}, 'Todo: Ruby example' if @state.selected == 'menu-ruby'
      div {className: 'menu-content'}, 'Todo Javascript example'  if @state.selected == 'menu-javascript'

UpBoxes = React.createClass
  render: ->
    div {id: 'upbox-rows'},
      for up in @props.ups
        UpBox(up)

UpBox = React.createClass
  classes: ->
    c = "upbox-row"
    if @props.status == 'UP'
      c += " status-up"
    else
      c += " status-down"
    c

  render: ->
    div {className: @classes()},
      div {className: 'upbox-right'},
        span {className: 'upbox-status'}, @props.status
        Sparkline({sparkline: @props.sparkline})
        # label {},
        #   input {type: 'checkbox'}
        #   "Monitor"
        # select {name: 'upbox'},
        #   option {}, "KeepAlive Alert",
        #   option {value: '1'}, "1 Minute"
        #   option {value: '5'}, "5 Minute"
        #   option {value: '60'}, "1 Hour"
      div {className: 'upbox-name'}, @props.name


Sparkline = React.createClass
  render: ->
    #console.log @props
    if @props.sparkline && @props.sparkline.length > 0
      img {src: "http://chart.apis.google.com/chart?cht=lc" +
        "&chs=100x30&chd=t:#{@props.sparkline.reverse()}&chco=666666" +
        "&chls=1,1,0" +
        "&chxt=r,x,y" +
        "&chxs=0,990000,11,0,_|1,990000,1,0,_|2,990000,1,0,_" +
        "&chxl=0:||1:||2:||" }



PhoneForm = React.createClass
  render: ->
    div {id: 'phone-form'},
      h3 {}, "Alert via SMS to"
      if @props.haveNumber
        VerifyPhoneForm()
      else
        if @props.verified
          div {},
            @props.alertNumber
        else
          EnterPhoneForm()

EnterPhoneForm = React.createClass
  handleSubmit: (e) ->
    console.log(e)
    e.preventDefault()
  render: ->
    form {onSubmit: @handleSubmit},
      label {},
        "Country Code"
        input {initialValue: "+", size: 5}
      label {},
        "Phone Number"
        input {initialValue: "3af", size: 15}
      div {},
        input {type: "submit", value: "Verify"}

VerifyPhoneForm = React.createClass
  handleSubmit: (e) ->
    console.log(e)
    e.preventDefault()

  render: ->
    form {onSubmit: @handleSubmit},
      label {},
        "Verification Code"
        input {}

class JSONUpCollection
  constructor: () ->
    @data = []

  getData: () ->
    @data

  add: (d) ->
    d.key = d.name
    found = false
    for val, key in @data
      if val.name == d.name
        found = true
        @data[key] = d

    @data.unshift(d) if not found


if window.location.hash && window.location.hash.length > 6
  UserID = window.location.hash.substring(1)
else
  UserID = Math.random().toString(36).substring(7)
  history.pushState(null, null, "##{UserID}") if history.pushState

collection = new JSONUpCollection

sockUrl = "ws://127.0.0.1:11112/#{UserID}"

handleMessage = (msg) ->
  d = JSON.parse(msg.data)
  console.log d
  collection.add(d)
  render()

document.addEventListener "DOMContentLoaded", (event) ->
  window.sock = new SocketHandler(sockUrl, handleMessage)
  render()

render = ->
  target = document.body
  React.render JSONUp(ups: collection.getData()), target, null
