script "Quit On Close Frontscript"
/**
Summary: Quits the application when the last relevenat window is closed.

Description:
When the user has closed all toplevel, non-editable, modeless, and collapsed stacks then
the application will automatically quit on all platforms except for macos. If you would like
a macos application to quit set the `quit on macos when all windows are closed` proprty to `true` in
the `app.yml` file.
*/
on closeStack
  local tStack
  local quitTheApp = true

  if levureApplicationState() is "shutting down" then pass closeStack

  put windowResolveTargetStack() into tStack

  if tStack is not empty then
    local tStackName, tMode

    put the short name of tStack into tStackName
    put the mode of tStack into tMode

    # Any mode greater than `modeless` should not trigger an application quit.
    if tMode > 3 then
      put false into quitTheApp
    else
      # As long as a stack with mode 1 or 2 is open we don't quit
      local tOpenStack

      repeat for each line tOpenStack in the openstacks
        if tOpenStack is tStackName then next repeat

        put the mode of stack tOpenStack into tMode
        # toplevel, non-editable, modeless, and collapsed stacks keep the app open
        if (tMode > 0 and tMode < 4) or tMode is 12 then
          put false into quitTheApp
          exit repeat
        end if
      end repeat
    end if

    if quitTheApp and the platform is "macos" then
      # Only quit on OS X if explicitly configured to do so
      if levureAppHasProperty("quit on macos when all windows are closed") and levureGetProp("quit on macos when all windows are closed") is true then
        put true into quitTheApp
      else
        put false into quitTheApp
      end if
    end if

    if quitTheApp then
      if the environment is not "development" then
        ## Use send so that closeStack passes through hierarchy before we quit
        send "_windowQuitApplication" to me in 0 milliseconds
      end if
    end if
  end if

  pass closeStack
end closeStack


command _windowQuitApplication
  quit
end _windowQuitApplication
