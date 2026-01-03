-- p_project.lua

-- treecatas表示一个功能点的界面树结构，
--   treecatas.plugins表示一个功能点的插件文件夹列表，
--   treecatas.treeitems表示一个功能点的显示的界面树项列表
-- projects表示一个项目列表，name表示一个项目的名称，title表示一个项目的标题，splash表示一个项目的启动图片，
--   catas表示一个项目的功能点的界面树结构列表，startcata表示一个项目的启动功能点，
-- dockside 表示一个项目的界面树是否停靠，showside表示一个项目的界面树是否显示，startproject表示一个项目的启动功能点
p_project =
{
	cfg = {
	    name = "cfg",
		dockside = false,
		showside = true,
		startproject = "minna",
	},
    treecatas = {
        {
            name = "home",
            title = "首页",
            show = true,
            expand = false,
            plugins = {
                "p_home",
            },
            treeitems = {
                "p_manykit",
            },
        },
        {
            name = "system",
            title = "设置",
            show = true,
            expand = false,
            plugins = {
                "p_system",
            },
            treeitems = {
                "p_system"
            },
        },
        {
            name = "net",
            title = "网络",
            show = true,
            expand = false,
            plugins = {
                "p_net",
            },
            treeitems = {
                "p_net",
                "p_holoserver",
            },
        },
        {
            name = "holospace",
            title = "空间",
            show = true,
            expand = false,
            plugins = {
                "p_holospace",
            },
            treeitems = {
                "p_holospace",
            },
        },
        {
            name = "mworld",
            title = "世界",
            show = true,
            expand = false,
            plugins = {
                "p_actor",
                "p_mworld",
            },
            treeitems = {
                "p_mworld",
            },
        },
        {
            name = "video",
            title = "视频",
            show = true,
            expand = false,
            plugins = {
                "p_video",
            },
            treeitems = {
                "p_video",
            },
        },
        {
            name = "videoview",
            title = "视频",
            show = true,
            expand = false,
            plugins = {
                "p_videoview",
            },
            treeitems = {
                "p_videoview",
            },
        },
        {
            name = "robot",
            title = "机器人",
            show = true,
            expand = false,
            plugins = {
                "p_actor",
                "p_robot",
                "p_holospace",
            },
            treeitems = {
                "p_robotface",
                "p_robot",
                "p_robotmusic",
                "p_robottime",
                "p_robotpath",
                "p_robotvoice",
            },
        }, 
        {
            name = "minna",
            title = "minna",
            show = true,
            expand = true,
            plugins = {
                "p_minna",
            },
            treeitems = {
                "p_minnastart",
                "p_minna",
            },
        },
    },
    projects = {
        {
            name = "MWorld",
            title = "MWorld",
            splash = "",
            treecatas = {
                "home",
                "video",
                "net",
                "holospace",
                "mworld",
                "robot",
            },
            startcata = "mworld",
        },
        {
            name = "minna",
            title = "minna",
            splash = "",
            treecatas = {
                "minna",
                "videoview",
                "net",
                "system",
            },
            startcata = "minna",
        },
    },
}
