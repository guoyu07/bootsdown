
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

# define jquery version
JQUERY_VERSION = '2.1.4'

# define jquery cdn
JQUERY_CDN =
    cdnjs: 'https://cdnjs.cloudflare.com/ajax/libs/jquery/{version}/jquery.min.js'
    staticfile: 'https://staticfile.qnssl.com/jquery/{version}/jquery.min.js'


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

        @loadMarkdown ->
            text = document.getElementById 'bootsdown'


        @loadBootstrap ->


    getMeta: (name, defaults = null) ->
        for meta in @metas
            return meta.getAttribute 'content' if name is meta.getAttribute 'name'
        defaults

    
    loadCss: (url, cb = null) ->
        link = document.createElement 'link'
        link.rel = 'stylesheet'
        link.type = 'text/css'
        link.href = url
        link.media = 'all'
        link.onload = cb if cb?

        @head.appendChild link


    loadJs: (url, cb = null) ->
        script = document.createElement 'script'
        script.src = url
        script.onload = cb if cb?

        @head.appendChild script


    loadMarkdown: (cb) ->
        url = MARKDOWN_CDN[@cdn]
        throw new Error "Markdown engine #{@markdown} is missing" if not url[@markdown]?
        parser = MARKDOWN[@markdown]

        @loadJs url[@markdown], cb.bind parser


    loadJQuery: (cb) ->
        url = JQUERY_CDN[@cdn]
        
        @loadJs (url.replace '{version}', JQUERY_VERSION), cb


    loadBootstrap: (cb) ->
        url = BOOTSTRAP_CDN[@cdn]
        parts = @theme.split ':'
        name = @theme
        theme = null
        jsFile = (url.path.basic.replace '{version}', BOOTSTRAP_VERSION.basic) + '/js/bootstrap.min.js'

        if parts > 1
            [name, theme] = parts

        cssFile = (url.path[name].replace '{version}', BOOTSTRAP_VERSION[name]
            .replace '{theme}', theme) + '/css/bootstrap.min.css'

        @loadJQuery => @loadJs url.prefix + jsFile, cb
        @loadCss url.prefix + cssFile


new Bootsdown

