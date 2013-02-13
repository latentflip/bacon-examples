tn = new Date().valueOf()
scale = d3.scale.linear().range([0,600]).domain([tn-10000, tn])
time = Bacon.fromPoll 1000/30, -> new Bacon.Next(new Date().valueOf())
time.map((t) -> [t-10000, t]).assign (ds) -> scale.domain(ds)

pMap = (fn) ->
  (p) ->
    {
      v: fn(p.v),
      color: p.color
    }


drawS = (title, stream) ->
  svg = d3.select('#bacon').append('svg')
  svg.append('text')
        .text(title)
        .attr({x: 5, y: 15})
  console.log(svg)
  circles = []

  stream = stream.map((p) -> { v: p.v, color: p.color, time: new Date().valueOf() })
  stream.assign (c) -> circles.push(c)
  
  drawCircles = ->
    sel = svg.selectAll('circle')
                .data(circles, (d) -> d.time)
    
    sel.enter().append('circle')
                .attr({cy: 40, r: 20, cx: 20})
                .attr('fill', (d) -> d.color)
                .attr('r', (d) -> d.v)


    sel.attr('cx', (d) -> scale(d.time))
    
    sel.exit().remove()

    tsel = svg.selectAll('text.p')
                .data(circles, (d) -> d.time)
    tsel.enter().append('text')
                    .attr('class', 'p')
                    .text( ((d) -> d.v.toString()))
                    .attr('y', 70)
                    .attr('text-anchor', 'middle')
    tsel.attr('x', (d) -> scale(d.time) )
    tsel.exit().remove()

  time.assign drawCircles


`
function get_random_color() {
  var letters = '0123456789ABCDEF'.split('');
    var color = '#';
    for (var i = 0; i < 6; i++ ) {
      color += letters[Math.round(Math.random() * 15)];
    }
    return color;
  }

`


textS = $('#myInput').asEventStream('keyup', (ev) -> parseInt($(ev.currentTarget).val()) ).map( (v) -> Math.min(v,20))
buttonS = $('#myInputButton').asEventStream('click', -> 3)
   
textS = textS.map((v) -> { v: v, color: get_random_color() })
buttonS = buttonS.map((v) -> { v: v, color: get_random_color() })
inputS = textS.merge(buttonS)

biggerS = inputS.map( pMap( (v) -> v * 3 ) )

#add = (a, b) -> a + b
#addS = biggerS.scan(0, (a,b)-> { v: (a.v||0)+(b.v||0), color: 'black'})
#slidingS = biggerS.slidingWindow(5).map( (v) ->
#  (v[0] + v[1] + v[2] + v[3] + v[4] + v[5])/5 )

delay = 0
setInterval (-> delay = Math.random()*2000), 100

drawS 'Text Box Changes', textS
drawS 'Button Changes', buttonS
drawS 'Text and button changes merged', inputS
drawS 'Merged mapped * 3', biggerS
#drawS 'Running Sum', slidingS

drawS 'FlatMap (add random delay)', biggerS.flatMap( (p) -> Bacon.later(delay, p) )
drawS 'FlatMapLatest (same random delay)', biggerS.flatMapLatest( (p) -> Bacon.later(delay, p) )
