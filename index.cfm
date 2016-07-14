<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>CFML Source Stats</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://maxcdn.bootstrapcdn.com/bootswatch/3.3.6/paper/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-1.12.0.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
  </head>

  <body>
  <nav class="navbar navbar-default navbar-static-top">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">CFML Source Stats</a>
        </div>
        <div id="navbar" class="navbar-collapse collapse">
          <ul class="nav navbar-nav">
            <li><a href="https://github.com/foundeo/cfmlstats">About</a></li>
            <li><a href="https://foundeo.com/contact/">Contact</a></li>         
          </ul>
          <ul class="nav navbar-nav navbar-right">
            <li><a href="https://foundeo.com/"><img src="https://foundeo.com/images/foundeo.png" width="70" height="20"></a></li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>
    </nav>
  <div class="container">
<cfsetting requesttimeout="99999">

<cfset options = StructNew()>



<cfset options.rootPath = ExpandPath("./")>
<cfset options.ignorePaths = [".svn", ".git"]>

<cfif NOT directoryExists(expandPath("./cfmlparser"))>
		<div class="alert alert-danger">You are missing dependencies <em>cfmlparser</em>, please run <code>box install</code></div>
</cfif>

<cfif NOT structKeyExists(form, "rootPath")>
	<h1>CFML Source Stats</h1>
	<form action="index.cfm" method="post" class="form">
		<div class="form-group">
    		<label for="rootPath">Root Path:</label>
    		<cfoutput><input type="text" name="rootPath" class="form-control" id="rootPath" placeholder="" value="#options.rootPath#"></cfoutput>
  		</div>
  		
  		
  		<button type="submit" class="btn btn-primary">Run</button>
	</form>
	<br>
	

<cfelse>
	<cfparam name="form.rootPath" default="">
	
	<cfset options.rootPath = form.rootPath>
	
	<div class="jumbotron">
	<h1>CFML Source Stats <small><cfoutput>#encodeForHTML(options.rootPath)#</cfoutput></small></h1>
	<div id="waiting" class="text-center">
	<iframe src="https://giphy.com/embed/oKVs1VY0MKfvO?html5=true" width="480" height="253" frameBorder="0" class="giphy-embed"></iframe><p><a href="http://giphy.com/gifs/nervous-indiana-jones-waiting-oKVs1VY0MKfvO">waiting... via GIPHY</a></p>
	</div>
	<cfflush>
	<cfset cfmlstats = new cfmlstats()>
	<cfset result = cfmlstats.run(options)>
	<script>document.getElementById("waiting").style.display="none";</script>
	
	<cfoutput>
	<div class="row">
		<div class="col-sm-2"><strong>Total CFML Files</strong></div>
		<div class="col-sm-2">#result.files#</div>
		<div class="col-sm-2"><strong>Lines of Code</strong></div>
		<div class="col-sm-2">#result.loc#</div>
	</div>
	<div class="row">
		<div class="col-sm-2"><strong>Application.cfc</strong></div>
		<div class="col-sm-2">#result.features.applicationCFC#</div>
		<div class="col-sm-2"><strong>Application.cfm</strong></div>
		<div class="col-sm-2">#result.features.applicationCFM#</div>
	</div>
	
	<div class="row">
		<div class="col-sm-2"><strong>Script CFCs</strong></div>
		<div class="col-sm-2">#result.features.scriptCFC#</div>
		<div class="col-sm-2"><strong>Tag CFCs</strong></div>
		<div class="col-sm-2">#result.features.tagCFC#</div>
	</div>
	</div>

	<h3>CFML Tags</h3>
	<cfset minUse = 0>
	<cfset tagsByUse = cfmlstats.sortByUsage(result.tags)>
	<table class="table table-striped table-bordered">
		<thead>
		<tr>
			<td>Rank</td>
			<td>Tag</td>
			<td>Usage</td>
			<td>Notes</td>
		</tr>
		</thead>
		<cfset rank = 0>
		<cfloop index="tag" array="#tagsByUse#">
			<tr>
				<td><cfset rank = rank+1>###rank#</td>
				<td>
					<cfif tag IS "!---">
						<em>CFML Comment</em>
					<cfelse>
						<a href="http://cfdocs.org/#encodeForURL(tag)#">#encodeForHTML(tag)#</a>
					</cfif>
				</td>
				<td>#result.tags[tag]#</td>
				<td>
					<cfset notes = cfmlstats.getNotes(tag)>
					<cfloop array="#notes#" index="item">
						<span class="label label-#encodeForHTMLAttribute(item.type)#">#encodeForHTML(item.note)#</span> &nbsp;
					</cfloop>
				</td>
			</tr>
		</cfloop>
	</table>

	<h3>CFML Functions</h3>
	<cfset minUse = 0>
	<cfset funcByUse = cfmlstats.sortByUsage(result.functions)>
	<table class="table table-striped table-bordered">
		<thead>
		<tr>
			<td>Rank</td>
			<td>Tag</td>
			<td>Usage</td>
			<td>Notes</td>
		</tr>
		</thead>
		<cfset rank = 0>
		<cfloop index="f" array="#funcByUse#">
			<tr>
				<td><cfset rank = rank+1>###rank#</td>
				<td>
					<a href="http://cfdocs.org/#encodeForURL(f)#">#encodeForHTML(f)#</a>
				</td>
				<td>#result.functions[f]#</td>
				<td>
					<cfset notes = cfmlstats.getNotes(f)>
					<cfloop array="#notes#" index="item">
						<span class="label label-#encodeForHTMLAttribute(item.type)#">#encodeForHTML(item.note)#</span> &nbsp;
					</cfloop>
				</td>
			</tr>
		</cfloop>
	</table>

	<cfif arrayLen(result.errors)>
		<h3>Errors</h3>
		<cfdump var="#result.errors#">
	</cfif>
	<cfif arrayLen(result.ignored)>
		<h3>Ignored #arrayLen(result.ignored)# Files</h3>
		<cfdump var="#result.ignored#" expand="false">
	</cfif>
	
	</cfoutput>
</cfif>
    
</div>	
    
	<br><br>
	<hr>
	<div class="text-center"><small>&copy; <a href="https://foundeo.com/">Foundeo Inc.</a> 2016</small></div>

  </body>
</html>
