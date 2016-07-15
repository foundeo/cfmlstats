component {
	variables.docBasePath = replace(getCurrentTemplatePath(), getFileFromPath(getCurrentTemplatePath()), "") & "cfdocs-site/data/en/";


	public struct function run(options) {
		var stats = {tags={}, functions={}, files=0, loc=0, features={scriptCFC=0,tagCFC=0,applicationCFC=0,applicationCFM=0}, errors=[], ignored=[]};
		var filePath = "";
		var fileArray = "";
		var parserFile = "";
		var statements = "";
		var ext = "";
		var tag = "";
		var i = "";
		var functions = [];
		var pos = 0;
		if (!structKeyExists(options, "fileFilter")) {
			options.fileFilter = "*.cfm|*.cfc|*.cfml";
		}
		if (!structKeyExists(options, "ignorePaths")) {
			options.ignorePaths = [];
		}



		try {
			if (fileExists(variables.docBasePath & "index.json")) {
				local.docIndex = deserializeJSON(fileRead(variables.docBasePath & "index.json"));
				functions = local.docIndex.functions;
			}
		} catch (any e) {
			//didnt load cfdocs
		}

		var fileArray = directoryList(options.rootPath, true, "path", options.fileFilter);



		for (filePath in fileArray) {
			try {
				if (fileExists(filePath)) {
					var skip = false;

					for (i in options.ignorePaths) {
						if (filePath contains i) {
							arrayAppend(stats.ignored, filePath);
							skip = true;
							break;
						}
					}

					if(skip){
						continue;
					}

					stats.files = stats.files + 1;

					parserFile = new cfmlparser.File(filePath);
					stats.loc = stats.loc + listLen(parserFile.getFileContent(), Chr(10));
					ext = listLast(filePath, ".");
					if (parserFile.isScript()) {
						stats.features.scriptCFC = stats.features.scriptCFC+1;
					} else if (ext == "cfc") {
						stats.features.tagCFC = stats.features.scriptCFC+1;
					}
					if (getFileFromPath(filePath) == "Application.cfc") {
						stats.features.applicationCFC = stats.features.applicationCFC+1;
					} else if (getFileFromPath(filePath) == "Application.cfm") {
						stats.features.applicationCFM = stats.features.applicationCFM+1;
					}
					if (!parserFile.isScript()) {
						statements = parserFile.getStatements();	
						for (tag in statements) {
							if (!structKeyExists(stats.tags, tag.getName())) {
								stats.tags[tag.getName()] = 1;
							} else {
								stats.tags[tag.getName()] = stats.tags[tag.getName()]+1;
							}
						}
					}

					for (i in functions) {
						pos = 1;
						while (pos != 0) {
							pos = reFindNoCase("[\t\r\n =!(##]#i#\s*\(", parserFile.getFileContent(), pos);
							if (pos != 0) {
								if (!structKeyExists(stats.functions, i)) {
									stats.functions[i] = 1;
								} else {
									stats.functions[i] = stats.functions[i]+1;
								}
								pos = pos + len(i)+2;
							}	
						}
						
					}


				}
			} catch(any e) {
				arrayAppend(stats.errors, {message=e.message, detail=e.detail, filePath=filePath});
			}
		}

		return stats;
	}

	public array function sortByUsage(struct s) {
		var result = [];
		var item = "";
		var r = "";
		var p = 0;
		var inserted = false;
		for (item in arguments.s) {
			if (arrayLen(result) == 0) {
				arrayAppend(result, item);
			} else {
				p = 1;
				inserted = false;
				for (r in result) {
					if (arguments.s[item] >= arguments.s[r]) {
						arrayInsertAt(result, p, item);
						inserted = true;
						break;
					}
					p++;
				}
				if (!inserted) {
					arrayAppend(result, item);
				}
			}

		}
		return result;
	}

	public array function getNotes(string name) {
		var result = [];
		var path = variables.docBasePath;
		if (listFindNoCase("cffile,cfinclude,cfmodule,cfzip,cfdocument,cfcontent,cfspreadsheet,cffileupload,cfexecute,spreadsheetwrite,spreadsheetread,spreadsheetreadbinary,imageread,imagewrite,cfdirectory,directorylist", arguments.name) || arguments.name contains "file") {
			arrayAppend(result, {note="May access filesystem", type="danger"});
		}
		if (listFindNoCase("cfajaxproxy,cfcalendar,cfchart,cfdiv,cfform,cfgrid,cflayout,cfmediaplayer,cfmap,cfmenu,cftextarea,cfpod, cfprogressbar,cfslider,cftooltip,cfwindow,cffileupload", arguments.name)) {
			arrayAppend(result, {note="UI Tags Require /cf_scripts or /CFIDE/scripts", type="warning"});
		}
		arguments.name = reReplace(arguments.name, "[^a-zA-Z_0-9-]", "", "ALL");
		path = path & arguments.name & ".json";
		try {
			if (fileExists(path)) {
				local.data = deserializeJSON(fileRead(path));
				if (structKeyExists(local.data, "discouraged") && len(local.data.discouraged)) {
					arrayAppend(result, {note="Discouraged: #local.data.discouraged#", type="warning"});
				}
				if (structKeyExists(local.data, "engines") && structKeyExists(local.data.engines, "coldfusion")) {
					if (structKeyExists(local.data.engines.coldfusion, "minimum_version") && len(local.data.engines.coldfusion.minimum_version)) {
						arrayAppend(result, {note="Requires ColdFusion #local.data.engines.coldfusion.minimum_version#+", type="info"});
						if (structKeyExists(local.data.engines, "lucee") && structKeyExists(local.data.engines.lucee, "minimum_version") && len(local.data.engines.lucee.minimum_version)) {
							result[arrayLen(result)].note = result[arrayLen(result)].note & " or Lucee #local.data.engines.lucee.minimum_version#+";
						}
					}
					if (structKeyExists(local.data.engines.coldfusion, "deprecated") && len(local.data.engines.coldfusion.deprecated)) {
						arrayAppend(result, {note="Deprecated in ColdFusion #local.data.engines.coldfusion.deprecated#", type="danger"});	
					}
					if (structKeyExists(local.data.engines.coldfusion, "removed") && len(local.data.engines.coldfusion.removed)) {
						arrayAppend(result, {note="Removed in ColdFusion #local.data.engines.coldfusion.removed#", type="danger"});	
					}
					if (!structKeyExists(local.data.engines, "lucee")) {
						arrayAppend(result, {note="Not supported on Lucee", type="info"});
					}
				} else if (structKeyExists(local.data.engines, "lucee")) {
					arrayAppend(result, {note="Lucee Specific, Not supported on ACF", type="info"});
				}

			}
		} catch (any e) {
			//ignore if some json parsing error			
		}

		return result;
	}



}