
# define bootstrap theme
BOOTSTRAP_THEME = [
    'basic'
    'bootswatch:cerulean'
    'bootswatch:cosmo'
    'bootswatch:cyborg'
    'bootswatch:darkly'
    'bootswatch:flatly'
    'bootswatch:journal'
    'bootswatch:lumen'
    'bootswatch:paper'
    'bootswatch:readable'
    'bootswatch:standstone'
    'bootswatch:simplex'
    'bootswatch:slate'
    'bootswatch:spacelab'
    'bootswatch:superhero'
    'bootswatch:united'
    'bootswatch:yeti'
]

# define bootstrap version
BOOTSTRAP_VERSION =
    basic: '3.3.6'
    bootswatch: '3.3.6'

# define bootstrap cdn
BOOTSTRAP_CDN =
    cdnjs:
        prefix: 'https://cdnjs.cloudflare.com/ajax/libs'
        path:
            basic: '/twitter-bootstrap/{version}'
            bootswatch: '/bootswatch/{version}/{theme}/bootstrap.min.css'
    staticfile:
        prefix: 'https://staticfile.qnssl.com'
        path:
            basic: '/twitter-bootstrap/{version}'
            bootswatch: '/bootswatch/{version}/{theme}/bootstrap.min.css'
    jsdelivr:
        prefix: 'https://cdn.jsdelivr.net'
        path:
            basic: '/bootstrap/{version}'
            bootswatch: '/bootswatch/{version}/{theme}/bootstrap.min.css'

# define jquery version
JQUERY_VERSION = '2.1.4'

# define jquery cdn
JQUERY_CDN =
    cdnjs: 'https://cdnjs.cloudflare.com/ajax/libs/jquery/{version}/jquery.min.js'
    staticfile: 'https://staticfile.qnssl.com/jquery/{version}/jquery.min.js'
    jsdelivr: 'https://cdn.jsdelivr.net/jquery/{version}/jquery.min.js'


# define markdown cdn
MARKDOWN_CDN =
    cdnjs:
        commonmark: 'https://cdnjs.cloudflare.com/ajax/libs/commonmark/0.24.0/commonmark.min.js'
        showdown: 'https://cdnjs.cloudflare.com/ajax/libs/showdown/1.3.0/showdown.min.js'
        pagedown: 'https://cdnjs.cloudflare.com/ajax/libs/pagedown/1.0/Markdown.Converter.min.js'
        marked: 'https://cdnjs.cloudflare.com/ajax/libs/marked/0.3.5/marked.min.js'
    staticfile:
        commonmark: 'https://staticfile.qnssl.com/commonmark/0.22.1/commonmark.min.js'
        showdown: 'http://cdn.staticfile.org/showdown/1.3.0/showdown.min.js'
        pagedown: 'http://cdn.staticfile.org/pagedown/1.0/Markdown.Converter.min.js'
    jsdelivr:
        showdown: 'https://cdn.jsdelivr.net/showdown/1.3.0/showdown.min.js'
        maked: 'https://cdn.jsdelivr.net/marked/0.3.5/marked.min.js'

# define markdown engine
MARKDOWN =
    commonmark: (markdown) ->
        reader = new commonmark.Parser
        writer = new commonmark.HtmlRenderer

        writer.softbreak = '<br />'
        writer.render reader.parse markdown

    showdown: (markdown) ->
        showdown.setOption 'noHeaderId', yes
        showdown.setOption 'strikethrough', yes
        showdown.setOption 'tables', yes

        converter = new showdown.Converter
        converter.makeHtml markdown

    pagedown: (markdown) ->
        converter = new Markdown.Converter
        converter.makeHtml markdown

    marked: (markdown) ->
        marked.setOptions
            gfm: yes
            tables: yes
            breaks: yes
            sanitize: yes
            smartLists: yes
            smartypants: no

        marked markdown
        


class Bootsdown

    constructor: ->
        @head = (document.getElementsByTagName 'head')[0]
        @isHttps = location.protocol is 'https:'
        @metas = document.getElementsByTagName 'meta'

        @cdn = @getMeta 'bootsdown:cdn', 'cdnjs'
        @theme = @getMeta 'bootsdown:theme', 'basic'
        @markdown = @getMeta 'bootsdown:markdown', 'commonmark'
        engine = null
        text = ''
        parsedText = null
        parseEventCount = 0
        renderEventCount = 0

        # create progressBar
        progressBar = document.createElement 'div'
        progressBar.style.position = 'absolute'
        progressBar.style.zIndex = 99999
        progressBar.style.height = '3px'
        progressBar.style.backgroundColor = '#F00'
        progressBar.style.top = 0
        progressBar.style.left = 0

        progress = ->
            percent = (parseEventCount + renderEventCount) * 20
            progressBar.style.width = percent + '%'
            document.body.removeChild progressBar if percent is 100

        parseText = ->
            parseEventCount += 1
            progress()
            return if parseEventCount isnt 2

            parsedText = engine text
            renderElement()

        renderElement = =>
            renderEventCount += 1
            console.log renderEventCount
            progress()
            return if renderEventCount isnt 3

            @render parsedText

        document.addEventListener 'DOMContentLoaded', ->
            document.body.appendChild progressBar
            scripts = document.getElementsByTagName 'script'

            for script in scripts
                if 'text/markdown' == script.getAttribute 'type'
                    text = script.innerHTML
                    break

            parseText()

        @loadMarkdown ->
            engine = @
            parseText()

        @loadBootstrap ->
            renderElement()
        , ->
            renderElement()


    render: (html) ->
        navBar = $ '<div class="navbar navbar-default navbar-fixed-top">
      <div class="container">
        <div class="navbar-header">
          <a href="#" class="navbar-brand" id="brand"></a>
          <button class="navbar-toggle" type="button" data-toggle="collapse" data-target="#navbar-main">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
        </div>
        <div class="navbar-collapse collapse" id="navbar-main">
            <ul class="nav navbar-nav" id="menu">
            </ul>
        </div>
    </div>
</div>
<div class="container" id="content"></div>'
            .appendTo document.body

        struct = @analyzeHtml html
        $ '#brand'
            .html struct.brand
        
        for k, v of struct.menu
            $ "<li><a href=\"##{k}\">#{v}</a></li>"
                .appendTo '#menu'


        $ document.body
            .css 'padding-top', navBar.outerHeight() + 20

        $ '#content'
            .show()


    analyzeHtml: (html) ->
        content = $ '#content'
            .hide()
            .html html

        h1 = $ 'h1'
            .get 0
        brand = ($ h1).text() if h1
        ($ h1).hide() if h1

        items = $ 'h2'
        menu = {}

        for item, i in items
            h2 = $ item
            id = 'goto-' + i
            h2.attr 'id', id
            menu[id] = h2.text()

        {brand, menu}


    getMeta: (name, defaults = null) ->
        for meta in @metas
            return meta.getAttribute 'content' if name is meta.getAttribute 'name'
        defaults

    
    loadCss: (url, cb = null) ->
        link = document.createElement 'link'
        @head.appendChild link
        
        link.onload = ->
            link.media = 'all'
            cb() if cb?

        link.onerror = ->
            cb() if cb?

        link.rel = 'stylesheet'
        link.type = 'text/css'
        link.href = url
        link.media = 'none'


    loadJs: (url, cb = null) ->
        script = document.createElement 'script'
        @head.appendChild script
        
        script.onload = cb if cb?
        script.src = url


    loadMarkdown: (cb) ->
        url = MARKDOWN_CDN[@cdn]
        throw new Error "Markdown engine #{@markdown} is missing" if not url[@markdown]?
        parser = MARKDOWN[@markdown]

        @loadJs url[@markdown], cb.bind parser


    loadJQuery: (cb) ->
        url = JQUERY_CDN[@cdn]
        
        @loadJs (url.replace '{version}', JQUERY_VERSION), cb


    loadBootstrap: (cbJs, cbCss) ->
        url = BOOTSTRAP_CDN[@cdn]
        parts = @theme.split ':'
        name = @theme
        theme = null
        jsFile = (url.path.basic.replace '{version}', BOOTSTRAP_VERSION.basic) + '/js/bootstrap.min.js'

        if parts.length > 1
            [name, theme] = parts

        cssFile = url.path[name].replace '{version}', BOOTSTRAP_VERSION[name]
            .replace '{theme}', theme

        cssFile += '/css/bootstrap.min.css' if parts.length is 1

        @loadJQuery =>
            @loadJs url.prefix + jsFile, cbJs
        @loadCss url.prefix + cssFile, cbCss


new Bootsdown

