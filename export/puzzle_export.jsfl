/************************************************
合并文件里的指定帧到muban.fla
并且将muban中的内容导出png图片到指定文件夹
*************************************************/

//资源停到的帧 
var _stopFrame = 3;
//文件名
var NAME = "muban";
//模板名字
var suffix = ".png";
var templeteName = NAME+suffix;
//模板文件完整路径
var templeteFullPath = null;
//版本号
var iVersion = 0;
//起始id
var startID = null;
//源文件
var sourceDom = null;
//v当前路径
var currentPath = null;
//当前文件名，不带后缀
var currentFileName = null;
//导出文件夹
var destPath = null;
//记录导出的文件名
var allPNG = "";
//物品资源模板
var itemDom = null;
/*
参数 格式 
name1=h-name2=v-name3=vh
name 要修改的元件名字
=之后为自选参数
v=垂直居中
h=水平居中
*/
var params = "";
 
start();
function start()
{
		var url = fl.browseForFileURL("open", "选择物品资源模板");
		if(url==null)
			return;
		itemDom = fl.openDocument(url);
        var folder = fl.browseForFolderURL("选择图块资源文件夹");
        if (! folder)
        {
                return;
        }
		destPath = fl.browseForFolderURL("选择导出目标文件夹");
        if (! destPath)
        {
                return;
        }
		trace(destPath);
        var paths = getAllFiles(folder);
        if (confirm("将要批量导出" + paths.length + "个文件"))
        {
                publish(paths);
        }
}
//导出
function exportPNG()
{
	var target = fl.openDocument(templeteFullPath);
	var lib = target.library;
	lib.editItem("empty");
	lib.selectItem("empty");
	var tl = lib.getSelectedItems()[0].timeline;
	//trace(tl.frameCount)
	tl.pasteFrames(0);	
	target.exitEditMode();
	var path = currentPath.replace(currentFileName, "");
	var savepath = FLfile.uriToPlatformPath(destPath) +"\\"+ currentFileName.replace(".fla", "");
	
	//修改导出配置
	var profile = target.exportPublishProfileString();
	var pngname = currentFileName.replace(".fla", ".png");
	profile = profile.replace("<defaultNames>1</defaultNames>", "<defaultNames>0</defaultNames>");
	profile = profile.replace("<pngDefaultName>1</pngDefaultName>", "<pngDefaultName>0</pngDefaultName>");
	profile = profile.replace("<pngFileName>"+NAME+"</pngFileName>", "<pngFileName>11"+pngname+"</pngFileName>");
	//trace(profile)
	while(profile.indexOf(NAME)!=-1)
	{
		profile = profile.replace(NAME, savepath);
	}
	target.importPublishProfileString(profile);
	updateItems(target);
	//发布文件
	//trace(target.exportPublishProfileString());
	target.publish(savepath, true);
	allPNG = allPNG + "\n" + savepath;
	fl.closeDocument(target, false);
	return profile;
}

function updateItems(dom)
{
	dom.selectAll();
	for (var i=0;i<dom.selection.length; ++i)
	{
		var item = dom.selection[i];
		allPNG = allPNG + "\n" + item.left+" " + item.name;
		executeParam(item, dom);
	}
}

function executeParam(item, dom)
{
	if(params==null || params=="")
		return;
	var pl = params.split("-");
	for each(var param in pl)
	{
		dom.selectNone();
		var paraminfo = param.split("=");
		var name = paraminfo[0];
		var values = paraminfo[1];
		if(item.name==name)
		{
			item.selected = true;
			var mx = 0;
			var my = 0;
			//水平居中
			if(values.indexOf("h")>=0)
			{
				mx = item.x-item.left-item.width/2;
			}
			//垂直居中
			if(values.indexOf("v")>=0)
			{
				my = item.y-item.top-item.height/2
			}
			dom.moveSelectionBy({x:mx, y:my})
		}else{
			item.selected = false;
		}
	}
}

//检查是否有指定参数
function checkParam(key)
{
	return params.search(key)>=0;
}

//从路径名分离出id和版本号
function spliceNameAndFrame(path)
{
	var parts = path.split("/");
	var name = parts[parts.length-2];
	parts = name.split("_");
	startID = parts[0];
	startID = startID.replace("[d]", currentFileName.replace(".fla", ""))
	iVersion = parts[1];
	params = parts[2] || "";
}

//设置模板文件路径
function buildTempletePath(path, fileName)
{
	trace(path + fileName);
	templeteFullPath = path.replace(fileName, templeteName);
}


function publish(paths)
{
/*
        if (paths.length > 20)
        {
                if (! confirm("文件比较多(" + paths.length + ")个,是否继续?"))
                {
                        return;
                }
        }
*/
        fl.outputPanel.clear();
        trace("开始批量发布");
		
		/*
		for each (var path in paths)
        {
				//跳过模板
				if(path.search(templeteName)>=0)
				{
					templeteFullPath = path;
					break
				}
		}
		*/
		
        for each (var path in paths)
        {
				trace(path);
				//跳过非png文件
				if(path.search(suffix)<=0)
				{
					continue;
				}
				//导入文件
				itemDom.importFile(path, true);
				//fl.closeDocument(sourceDom, false);
        }
       trace(allPNG);
}

function trace(string)
{
	fl.trace(string);
}

function getFiles(folder, type)
{
        return FLfile.listFolder(folder+"/*."+type,"files");
}
function getFolders(folder)
{
        return FLfile.listFolder(folder+"/*","directories");
}
function getAllFiles(folder)
{
        //递归得到文件夹内所有as文件
        var list = getFiles(folder, "png").concat(getFiles(folder, "xfl"));
        var i = 0;
        for each (var file in list)
        {
                list[i] = folder + "/" + file;
                i++;
        }
        var folders = getFolders(folder);
        for each (var childFolder in folders)
        {
                list = list.concat(getAllFiles(folder + "/" + childFolder));
        }
        return list;
}