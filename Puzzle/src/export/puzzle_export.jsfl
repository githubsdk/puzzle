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
//图块矩形宽高
var chipWidth = 0;
var chipHeight = 0;
//图块形状信息列表
var chipInfo = null;
/*
参数 格式 
name1=h-name2=v-name3=vh
name 要修改的元件名字
=之后为自选参数
v=垂直居中
h=水平居中
*/
var params = "";

var included = {};
function include(file) {
	if (included[file]) { return; }
	included[file] = true;
	eval(FLfile.read(SCRIPT_PATH+file+".jsfl"));
}

var SCRIPT_PATH = getFolderPath(fl.scriptURI,1);

var OUT_PUT_CONTENT = FLfile.read(getFolderPath(fl.scriptURI,2)+"info.json");

include("JSON");
PUBLISH_INFO = JSON.decode(OUT_PUT_CONTENT);

function getFolderPath(url,popCount)
{
	//var url = fl.scriptURI;

	var parts = url.split("/");
	var script_name;
	for(var i=0;i<popCount;++i)
	{
		script_name = parts.pop();
	}
	
	url = parts.join("/");
	return url+"/";
}

 
start();
function start()
{
		var url = SCRIPT_PATH+"item.fla";
		itemDom = fl.openDocument(url);
        var folder = PUBLISH_INFO.folder;
       
		destPath = folder;
        
		trace(destPath);
        var paths = getAllFiles(folder);
        publish(paths);
        return;
        if (confirm("将要批量导出" + paths.length + "个文件"))
        {
                //publish(paths);
        }
}
//导出
function exportItem()
{
	var lib = itemDom.library;
	var scale = 1;
	for (var key in chipInfo)
	{
		lib.editItem("Icon");
		itemDom.selectAll();
		if(itemDom.selection!=null && itemDom.selection.length>0)
			itemDom.deleteSelection();
		lib.selectItem(key + ".png");
		var item = lib.getSelectedItems();
		lib.addItemToDocument({x:0, y:0});
		
		itemDom.selectAll();
		var pos = chipInfo[key];
		itemDom.selection[0].x = Number(pos.x)-chipWidth/2;
		itemDom.selection[0].y = Number(pos.y)-chipHeight/2;
		itemDom.selection[0].scaleX = itemDom.selection[0].scaleY = scale;
		itemDom.traceBitmap(1,1,"smooth", "normal");
		var path = destPath+"/"+key+".swf";
		trace(path);
		itemDom.exportSWF(path);
	}
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
	iVersion = parts[0];
	params = parts[2] || "";
}

//设置模板文件路径
function buildTempletePath(path, fileName)
{
	trace(path + fileName);
	templeteFullPath = path.replace(fileName, templeteName);
}

//解析信息文件内容
function parseInfo(content)
{
	
	chipInfo = {};
	for each(var pos in PUBLISH_INFO.pos)
	{
		chipInfo[pos.id] = {x:pos.x, y:pos.y};
	}

	chipWidth = PUBLISH_INFO.size.width;
	chipHeight = PUBLISH_INFO.size.height;
}

function publish(paths)
{		
		parseInfo(null);
        for each (var path in paths)
        {
				if(path.search(suffix)<=0)
				{
					//跳过非png文件
					continue;
				}
				//导入文件
				itemDom.importFile(path, true);
				//fl.closeDocument(sourceDom, false);
        }
		
		exportItem();
		fl.closeDocument(itemDom, false);
       //trace(allPNG);
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
        var list = getFiles(folder, "png").concat(getFiles(folder, "txt"));
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