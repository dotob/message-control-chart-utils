program  = require 'commander'
wsd      = require 'websequencediagrams'
fs       = require 'fs'
path     = require 'path'
dir      = require 'node-dir'
chokidar = require 'chokidar'

# setup
wsd.root = "http://gs2-message-sequence-charts:1086"
#wsd.root = "http://localhost:1086"

convertAll = (format) ->
	console.log "convert...(=> #{format})"
	dir.readFiles "..", {
		match: /.msc$/
		exclude: /^\./
	}, ((err, content, filename, next) ->
		if err
			throw err
		convertOne content, filename, format, next
	), (err, files) ->
		if err
			throw err

convertOne = (content, filepath, format, next) ->
	#console.log 'content:', content
	wsd.diagram content, 'rose', format, (er, buf) ->
		if er
			throw er
		else
			filename = path.basename filepath
			f = "#{filename}.#{format}"
			fs.writeFile f, buf, (e) ->
				if e
					throw e
				else
					console.log "created #{f}"
					if next
						next()


program.version '0.0.1'
program.usage('[options] <convert|watch>')

program
	.command 'watch'
	.description "watch for changes and convert to pdf or png"
	.option '--format <type>', 'Output format ([pdf|png])', /^(png|pdf)$/i, 'pdf'
	.action (options) ->
		convertAll(options.format)
		console.log "watch msc files..."
		chokidar.watch('../*.msc').on 'change', (path) ->
			fs.readFile path, 'utf-8', (err, content) ->
				if err
					throw err
				else
					convertOne content, path, options.format

program
	.command 'convert'
	.description "convert to pdf or png"
	.option '-f, --format <type>', 'Output format ([pdf|png])', /^(png|pdf)$/i, 'pdf'
	.action (options) ->
		convertAll(options.format)

program.parse process.argv

