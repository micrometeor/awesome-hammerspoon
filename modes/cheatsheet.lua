------------------------------------------------------------------------
--/ Cheatsheet Copycat /--
------------------------------------------------------------------------

--commandEnum = {
--        [0] = '⌘',
--        [1] = '⇧ ⌘',
--        [2] = '⌥ ⌘',
--        [3] = '⌥ ⇧ ⌘',
--        [4] = '⌃ ⌘',
--        [5] = '⇧ ⌃ ⌘',
--        [6] = '⌃ ⌥ ⌘',
--        [7] = '',
--        [8] = '⌦',
--        [9] = '',
--        [10] = '⌥',
--        [11] = '⌥ ⇧',
--        [12] = '⌃',
--        [13] = '⌃ ⇧',
--        [14] = '⌃ ⌥',
--    }
commandEnum = {
    ['cmd'] = '⌘',
    ['shift'] = '⇧',
    ['alt'] = '⌥',
    ['ctrl'] = '⌃',
}


function getAllMenuItemsTable(t)
    local menu = {}
    for pos,val in pairs(t) do
        if(type(val)=="table") then
            if(val['AXRole'] =="AXMenuBarItem" and type(val['AXChildren']) == "table") then
                menu[pos] = {}
                menu[pos]['AXTitle'] = val['AXTitle']
                menu[pos][1] = getAllMenuItems(val['AXChildren'][1])
            elseif(val['AXRole'] =="AXMenuItem" and not val['AXChildren']) then
                if( val['AXMenuItemCmdModifiers'] ~='0' and val['AXMenuItemCmdChar'] ~='') then
                    menu[pos] = {}
                    menu[pos]['AXTitle'] = val['AXTitle']
                    menu[pos]['AXMenuItemCmdChar'] = val['AXMenuItemCmdChar']
                    menu[pos]['AXMenuItemCmdModifiers'] = val['AXMenuItemCmdModifiers']
                end
            elseif(val['AXRole'] =="AXMenuItem" and type(val['AXChildren']) == "table") then
                menu[pos] = {}
                menu[pos][1] = getAllMenuItems(val['AXChildren'][1])
            end
        end
    end
    return menu
end


function getAllMenuItems(t)
    local menu = ""
        for pos,val in pairs(t) do
            if(type(val)=="table") then
                -- do not include help menu for now until I find best way to remove menubar items with no shortcuts in them
                if(val['AXRole'] =="AXMenuBarItem" and type(val['AXChildren']) == "table") and val['AXTitle'] ~="Help" then
                    menu = menu.."<ul class='col col"..pos.."'>"
                    --print("---------------| "..val['AXTitle'].." |---------------")
                    menu = menu.."<li class='title'><strong>"..val['AXTitle'].."</strong></li>"
                    menu = menu.. getAllMenuItems(val['AXChildren'][1])
                    menu = menu.."</ul>"
                elseif(val['AXRole'] =="AXMenuItem" and not val['AXChildren']) then
                    if( val['AXMenuItemCmdChar'] ~= '') then
                        CmdModifiers = ''
                        for key, value in pairs(val['AXMenuItemCmdModifiers']) do
                            CmdModifiers = CmdModifiers..commandEnum[value]
                        end
                        menu = menu.."<li><div class='cmdModifiers'>"..CmdModifiers.." "..val['AXMenuItemCmdChar'].."</div><div class='cmdtext'>".." "..val['AXTitle'].."</div></li>"
                    end
                elseif(val['AXRole'] =="AXMenuItem" and type(val['AXChildren']) == "table") then
                    menu = menu..getAllMenuItems(val['AXChildren'][1])
                end

            end
        end
    return menu
end

function generateHtml()
    --local focusedApp= hs.window.frontmostWindow():application()
    local focusedApp = hs.application.frontmostApplication()
    local appTitle = focusedApp:title()
    local allMenuItems = focusedApp:getMenuItems();
    local myMenuItems = getAllMenuItems(allMenuItems)

    local html = [[
        <!DOCTYPE html>
        <html>
        <head>
        <style type="text/css">
            *{margin:0; padding:0;}
            html, body{
              background-color:#eee;
              font-family: arial;
              font-size: 13px;
            }
            a{
              text-decoration:none;
              color:#000;
              font-size:12px;
            }
            li.title{ text-align:center;}
            ul, li{list-style: inside none; padding: 0 0 5px;}
            footer{
              position: fixed;
              left: 0;
              right: 0;
              height: 48px;
              background-color:#eee;
            }
            header{
              position: fixed;
              top: 0;
              left: 0;
              right: 0;
              height:48px;
              background-color:#eee;
              z-index:99;
            }
            footer{ bottom: 0; }
            header hr,
            footer hr {
              border: 0;
              height: 0;
              border-top: 1px solid rgba(0, 0, 0, 0.1);
              border-bottom: 1px solid rgba(255, 255, 255, 0.3);
            }
            .title{
                padding: 15px;
            }
            li.title{padding: 0  10px 15px}
            .content{
              padding: 0 0 15px;
              font-size:12px;
              overflow:hidden;
            }
            .content.maincontent{
            position: relative;
              height: 577px;
              margin-top: 46px;
            }
            .content > .col{
              width: 23%;
              padding:20px 0 20px 20px;
            }

            li:after{
              visibility: hidden;
              display: block;
              font-size: 0;
              content: " ";
              clear: both;
              height: 0;
            }
            .cmdModifiers{
              width: 60px;
              padding-right: 15px;
              text-align: right;
              float: left;
              font-weight: bold;
            }
            .cmdtext{
              float: left;
              overflow: hidden;
              width: 165px;
            }
        </style>
        </head>
          <body>
            <header>
              <div class="title"><strong>]]..appTitle..[[</strong></div>
              <hr />
            </header>
            <div class="content maincontent">]]..myMenuItems..[[</div>
            <br>

          <footer>
            <hr />
              <div class="content" >
                <div class="col">
                  by <a href="https://github.com/dharmapoudel" target="_parent">dharma poudel</a>
                </div>
              </div>
          </footer>
          <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.isotope/2.2.2/isotope.pkgd.min.js"></script>
            <script type="text/javascript">
              var elem = document.querySelector('.content');
              var iso = new Isotope( elem, {
                // options
                itemSelector: '.col',
                layoutMode: 'masonry'
              });
            </script>
          </body>
        </html>
        ]]

    return html
end



myView = nil

function showCheatsheet()
    local frame = hs.geometry.rect(hs.screen.mainScreen():frame().topleft, "1080*600")
    if not myView then
        myView = hs.webview.new(frame)
        :windowStyle("utility")
        :closeOnEscape(true)
        :html(generateHtml())
        :allowGestures(true)
        :allowNewWindows(false)
        :windowTitle("CheatSheets")
        :level(hs.drawing.windowLevels.modalPanel)
        :show()
    end
end

cheatsheetM = hs.hotkey.modal.new()
local modalpkg = {}
modalpkg.id = "cheatsheetM"
modalpkg.modal = cheatsheetM
table.insert(modal_list, modalpkg)

function cheatsheetM:entered()
    modal_stat('cheatsheet',sandybrown)
    for i=1,#modal_list do
        if modal_list[i].id == "cheatsheetM" then
            table.insert(activeModals, modal_list[i])
        end
    end
    showCheatsheet()
    if nettimer~=nil and nettimer:running() then nettimer:stop() end
end

function cheatsheetM:exited()
    for i=1,#activeModals do
        if activeModals[i].id == "cheatsheetM" then
            table.remove(activeModals, i)
        end
    end
    if dock_launched then
        if idle_to_which == "netspeed" then
            modal_stat('netspeed',black50)
            disp_netspeed()
        elseif idle_to_which == "hide" then
            modal_show:hide()
            modal_bg:hide()
        elseif idle_to_which == "never" then
            modal_stat('dock',black)
        end
    end
    if myView ~= nil then myView:delete() myView=nil end
end

cheatsheetM:bind('', 'escape', function() cheatsheetM:exit() end)
cheatsheetM:bind('', 'Q', function() cheatsheetM:exit() end)
