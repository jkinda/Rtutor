


examples.show.shiny.ps = function() {
  library(restorepoint)
  set.restore.point.options(display.restore.point=TRUE)
  #options(shiny.error=browser)
  library(RTutor)
  setwd("D:/libraries/RTutor/examples")
  ps.name = "Example"
  show.ps(ps.name, launch.browser=TRUE, import.rmd=TRUE)

  show.shiny.ps(ps.name, user.name="default_user", load.sav=FALSE, sample.solution=FALSE, import.rmd=TRUE, catch.errors=FALSE)

  show.shiny.ps(ps.name, user.name="default_user", load.sav=TRUE)
  show.shiny.ps(ps.name, launch.browser=TRUE)

  windows(title="Plots")

  setwd("D:/libraries/RTutor/examples")
  ps.name = "The Impact of Shrouded Fees 3"
  show.shiny.ps(ps.name, load.sav=FALSE, launch.browser=TRUE, sample.solution=TRUE, run.solved=TRUE)

  show.shiny.ps(ps.name, launch.browser=TRUE)

  options(shiny.error=traceback)
  show.shiny.ps(ps.name)
}



#' Run a shiny based problem set in the browser
#'
#' Main function to locally run a shiny based problem set in your browser. There are a lot of parameters that control the behavior of the problem set. Only the main parameters are explained below.
#' 
#' @param ps.name Name of the problem set
#' @param user.name A user name. Should be a valid variable name
#' @param auto.save.code If TRUE all entered code will be automatically saved for the user. If FALSE (default) no entered code is saved. The user statistics (how many chunks are solved) are still saved, however.
#' @param run.solved If TRUE and also sample.solution=TRUE all previously solved chunks will be run when the problem set is newly shown. This can be very time consuming. I would suggest in most cases to keep the default run.solved=FALSE. 
#' @param clear.user If TRUE all previously saved data for the user is removed if the problem set starts. Can be useful for development or for resetting things.
#' @param sample.solution If TRUE the sample solution is shown in all chunks. Can be useful when developing a problem set. Note that one can create a problem set such that the sample solution is not available, e.g. if one wants to avoid that students just look at the sample solution.
#' @param show.solution.btn If TRUE add a button to each chunk to show the sample solution. Note that one can create a problem set such that the sample solution is never available. By default TRUE if a sample solution is available in the problem set.
#' @param prev.chunks.sample.solution If TRUE and a user edits a chunk without having checked all previous chunks then previous chunks will be automatically be checked with the sample solution. If FALSE previous chunks will be checked with the user's entered solutions. Has by default the same value as show.solution.btn.
#' @param show.download.rmarkdown If TRUE the user is able to download the R-Markdown file of their solution in the submissions-tab. If FALSE the corresponding button is not rendered. By default set to \code{TRUE}.
#' @param launch.browser if TRUE (default) show the problem set in the browser. Otherwise it is shown in the RStudio viewer pane
#' @param catch.errors by default TRUE only set FALSE for debugging purposes in order to get a more informative traceback()
#' @param offline (FALSE or TRUE) Do you have no internet connection. By default it is checked whether RTutor can connect to the MathJax server. If you have no internet connection, you cannot render mathematic formulas. If RTutor wrongly thinks you have an internet connection, while you don't, your chunks may not show at all. If you encounter this problem, set manually offline=TRUE.
#' @param html.data.frame shall data.frames and matrices be printed as html table if a chunk is checked? (Default=TRUE)
#' @param table.max.rows the maximum number of rows that is shown if a data.frame is printed as html.table
#' @param round.digits the number of digits that printed data.frames shall be rounded to
#' @param dir your working directory for the problem set, by default getwd()
#' @param rps.dir directory of rps.files by default equal to dir
show.ps = function(ps.name, user.name="default_user", auto.save.code = FALSE,clear.user=FALSE,run.solved=FALSE,sample.solution=FALSE, prev.chunks.sample.solution = show.solution.btn,launch.browser=TRUE, catch.errors = TRUE,  dir=getwd(), rps.dir=dir, offline=!can.connect.to.MathJax(), left.margin=2, right.margin=2, is.solved, make.web.app=FALSE, make.session.ps=make.web.app, save.nothing=FALSE, show.revert.btn=TRUE, show.solution.btn = NA, show.data.exp=TRUE, show.download.rmarkdown=TRUE, disable.graphics.dev=TRUE,  check.whitelist=!is.null(wl), wl=NULL, verbose=FALSE, html.data.frame=TRUE,table.max.rows=25, round.digits=8, signif.digits=8, knit.print.opts=make.knit.print.opts(html.data.frame=html.data.frame,table.max.rows=table.max.rows, round.digits=round.digits, signif.digits=signif.digits,print.data.frame.fun=print.data.frame.fun,print.matrix.fun=print.matrix.fun), print.data.frame.fun = NULL, print.matrix.fun=NULL, precomp=FALSE, noeval=FALSE, need.login=FALSE, login.dir = paste0(dir,"/login"), show.points=TRUE,  stop.app.if.window.closes=!make.session.ps,sav.file=paste0(user.name, "_", ps.name,".sav"), load.sav = FALSE,  show.save.btn=FALSE,   import.rmd=FALSE, rmd.file = paste0(ps.name,"_",user.name,"_export.rmd"),  ...) {

  cat("\nInitialize problem set, this may take a while...")
  app = eventsApp(verbose = verbose)

  
  shiny::addResourcePath("figure",dir)
  #browser()
  ps = init.shiny.ps(
    ps.name=ps.name, user.name=user.name,sav.file=sav.file,
    load.sav=load.sav, sample.solution=sample.solution, 
    prev.chunks.sample.solution=prev.chunks.sample.solution,
    run.solved = run.solved,import.rmd=import.rmd,
    rmd.file=rmd.file,
    dir=dir, rps.dir=rps.dir, save.nothing=save.nothing,
    show.solution.btn = show.solution.btn,
    show.revert.btn = show.revert.btn,
    show.data.exp=show.data.exp,
    show.save.btn = show.save.btn,
    show.download.rmarkdown = show.download.rmarkdown,
    clear.user=clear.user,
    check.whitelist=check.whitelist, wl=wl,
    precomp=precomp, noeval=noeval, 
    auto.save.code=auto.save.code, ...
  )
  
  if (is.null(ps$rps$cdt$task.html)) {
    stop("This problem set has been compiled without any HTML information. It cannot be solved in the web browser by calling show.ps(). You need the empty problem set Rmd file and solve it inside RStudio.")
  }

  
  ps$show.points = show.points
  ps$need.login = need.login
  ps$login.dir = login.dir
  
  ps$catch.errors = catch.errors
  ps$offline=offline
  ps$left.margin = left.margin
  ps$right.margin = right.margin

  # Replace knit.print.funs in globalenv
#  knit.print.funs = make.knit.print.funs(knit.print.opts)
#  old.knit.print.funs = replace.fields(dest=globalenv(), source=knit.print.funs)
  
  # Need to call register 
  
  # restore old functions on exit
#  if (!make.web.app)
#    on.exit(replace.fields(dest=globalenv(), source=old.knit.print.funs), add=TRUE)

  # We need now to explicitly call registerS3method
  register.knit.print.functions(knit.print.opts)
  
  knitr.opts.chunk = ps$rps[["knitr.opts.chunk"]]
  
  # Try to avoid problem if X-Quartz is missing on Mac 
  if (isTRUE(knitr.opts.chunk[["dev"]] == "svg")) {
    svg.works = !is(try({svg(); dev.off()}, silent=TRUE), "try-error" )
    if (!svg.works) {
      if (require("svglite")) {
        knitr.opts.chunk$dev = "svglite"
      } else {
        knitr.opts.chunk$dev = "png"
        warning("Cannot use the default SVG device. Chunks will output PNG graphs instead. Try to install the package 'svglite' by typing\n\ninstall.packages('svglit')\n\nAlternatively, if you are using a Mac, try to install X-Quartz (a link is given on the R installation page for Mac).")
      }
    }
  }
  
  if (!is.null(knitr.opts.chunk)) {
    do.call(knitr::opts_chunk$set,knitr.opts.chunk)
  }
  
  restore.point("show.shiny.ps")

  n = NROW(ps$cdt)


  ps$view.in.container = FALSE
  ui = make.rtutor.ui()
  
  ex.inds = 1:NROW(ps$edt)
  #ex.inds = 1:2
  for (ex.ind in ex.inds)
    show.ex.ui(ex.ind)

  for (chunk.ind in seq_len(n)) {
    make.chunk.handlers(chunk.ind=chunk.ind)
  }
  make.load.save.handlers()

  txt = as.character(ui)
  setAppUI(ui, app)


  if (make.session.ps) {
    app$initHandler = function(session, input, output,app,...) {
      # make local copy of ps
      ops = get.ps(TRUE)
      ops$running.web.app = TRUE
      ps = copy.ps.for.session(ops)

      app$ps = ps
      ps$session = session
      ps$input = input
      ps$output = output
      # autocomplete in first open chunk
      if(NROW(ps$cdt)>0){
        set.chunk.autocomp.observer(inputId = ps$cdt$nali[[1]]$editor, chunk.ind = 1)
      }

    }
  } else {
    app$initHandler = function(session, input, output,...) {
      ps = get.ps(TRUE)
      
      ps$running.web.app = TRUE
      ps$session = session
      ps$input = input
      ps$output = output
      
      # autocomplete in first open chunk
      if(NROW(ps$cdt)>0){
        set.chunk.autocomp.observer(inputId = ps$cdt$nali[[1]]$editor, chunk.ind = 1)
      }
      if (stop.app.if.window.closes) {
        session$onSessionEnded(function() {stopApp()})
      }
    }
  }

  if (make.web.app) {
    return(app)
  }

  if (!isTRUE(launch.browser))
    launch.browser = rstudioapi::viewer


  if (disable.graphics.dev) {
    try(png("NUL"),silent=TRUE)
    on.exit(try(dev.off(),silent=TRUE), add=TRUE)
  }

  
  runEventsApp(app=app,ui=ui,launch.browser=launch.browser, quiet=FALSE)

}

show.shiny.ps = show.ps

init.shiny.ps = function(ps.name,dir=getwd(), user.name="default_user",  sav.file=NULL, load.sav = !is.null(sav.file), ex.inds =NULL, sample.solution=FALSE, prev.chunks.sample.solution=show.solution.btn, run.solved=load.sav, import.rmd=FALSE, rmd.file = paste0(ps.name,"_",user.name,"_export.rmd"), rps.dir=dir, ups.dir=dir, save.nothing=FALSE, show.solution.btn=NA, show.revert.btn=TRUE, show.data.exp=TRUE, show.download.rmarkdown=TRUE, clear.user = FALSE, check.whitelist=!is.null(wl), wl=NULL, precomp=FALSE, noeval=FALSE, replace.sol=precomp, preknit=FALSE, ups.save = default.ups.save(code=auto.save.code), show.load.save.panel=FALSE, show.export.panel=TRUE, show.save.btn=FALSE,log.file = paste0(dir,"/",ps.name,".log"), auto.save.code=FALSE, ...) {
  restore.point("init.shiny.ps")
  setwd(dir)

  ps = init.ps(ps.name,user.name, dir=dir, rps.dir=rps.dir, ups.dir=ups.dir, save.nothing=save.nothing, check.whitelist=check.whitelist, wl=wl, precomp=precomp, noeval=noeval, replace.sol=replace.sol, preknit=preknit, ups.save=ups.save, log.file=log.file)

  ps$run.solved = run.solved
  
  ps$sav.file = sav.file
  if (load.sav & !clear.user) {
    ups = load.sav(sav.file, ps=ps)
    if (!is.null(ups))
      ps$ups = ups
  }
  if (!is.null(ps$rps$cdt.hash) & !is.null(ps$ups$cdt.hash)) {
    if (ps$rps$cdt.hash != ps$ups$cdt.hash) {
      cat("\nClear user data since problem set structure has changed...\n")
      clear.user = TRUE
    }
  }
  if (clear.user) {
    ps$ups = init.ups(user.name = user.name, ps=ps)
  }
  
  ps$show.load.save.panel=show.load.save.panel
  ps$show.export.panel=show.export.panel
  ps$show.save.btn = show.save.btn
  ps$show.download.rmarkdown = show.download.rmarkdown
  
  ps$is.shiny = TRUE
  if (is.na(show.solution.btn))
    show.solution.btn = isTRUE(ps$rps$has.sol)
  ps$show.solution.btn = show.solution.btn

  if (is.na(prev.chunks.sample.solution))
    prev.chunks.sample.solution = isTRUE(ps$rps$has.sol)
  ps$prev.chunks.sample.solution = prev.chunks.sample.solution
  
  
  ps$show.revert.btn = show.revert.btn
  ps$show.data.exp = show.data.exp

  ps$shiny.ex.inds = ex.inds
  ps$shiny.dt = ps$rps$shiny.dt
  ps$chunk.ind = 0
  #ps$shiny.dt$code

  n = NROW(ps$cdt)
  
  ps$button.counter = list()
  
  cdt = as_tibble(ps$cdt)
  
  cdt$nali = replicate(n, list(), simplify=FALSE)
  cdt$ui = replicate(n, list(), simplify=FALSE)

  cdt$has.output.observer = rep(FALSE,n)
  cdt$has.input.observer = rep(FALSE,n)
  cdt$has.ui.renderer = rep(FALSE,n)
  cdt$server = replicate(n, expression(), simplify=FALSE)

  ps$cdt = as.data.table(cdt)
  
  for (chunk.ind in ps$cdt$chunk.ps.ind) {
    id = paste0("r.chunk_",chunk.ind,".ui.mode")
    ps[[id]] = reactiveValues(counter=0)
    # r.chunk.ui.mode = reactiveValues(counter=0)
  }


  if (sample.solution & !ps$rps$has.sol) {
    warning("I cannot show the sample solution, since the sample solution was not made available for the problem set.")
    sample.solution = FALSE
  }
  ps$show.sample.solution = sample.solution

  # init addons for shiny
  for (ao in ps$rps$addons) {
    Addon = ps$rps$Addons[[ao$rta$type]]
    Addon$shiny.init.fun(ao=ao,ps=ps)
  }

  ups.init.shiny.ps(ps=ps, ups=ps$ups, sample.solution=sample.solution, ups.save=ups.save, rerun = isTRUE(ps$run.solved))  
  
  show.shiny.awards()
  
  changeHandler("exTabsetPanel",rtutor.ex.tab.change)

  set.ps(ps)
}

rtutor.ex.tab.change = function(value,...) {
  if (identical(value,"statsPanel")) {
    rtutor.update.stats.panel()
  }
}


# observe.nextExBtns = function(session, ps=get.ps()) {
#   restore.point("observe.nextExBtns")
#   cdt = ps$cdt
#   ex.inds = setdiff(unique(cdt$ex.ind),0)
#   if (!is.null(ps$shiny.ex.inds))
#     ex.inds = intersect(ex.inds, ps$shiny.ex.inds)
# 
# 
#   ex.ind = 1
#   for (ex.ind in setdiff(ex.inds,max(ex.inds))) {
#     btn = paste0(paste0("nextExBtn", ex.ind))
#     observe({
#       #cat("observe ", btn)
#       if (has.counter.increased(btn, session$input[[btn]])) {
#         #cat("Go to exercise ",paste0("exPanel",ex.ind+1),"...")
#         updateTabsetPanel(session, inputId="exTabsetPanel", selected = paste0("exPanel",ex.ind+1))
#       }
#     })
#   }
# }


rtutor.eval.to.string = function(code, envir=parent.frame(), convert=TRUE, check.whitelist=isTRUE(ps$check.whitelist), ps=get.ps()) {
  restore.point("rtutor.eval.to.string")
  txt = sep.lines(code)
  ok = FALSE

  all.str = tryCatch({
      expr.li <- parse.text.with.source(txt)
      ok <- TRUE
    },
    error = function(e) {
      as.character(e)
    }
  )

  if (ok & check.whitelist) {
    res = rtutor.check.whitelist(expr.li,ps=ps)
    ok = res$ok
    if (!ok) {
      all.str = res$msg
    }
  }

  if (ok) {
    if (isTRUE(ps$use.secure.eval)) {
      all.str = try(rtutor.eval.secure(inner.rtutor.eval.to.string(expr.li, envir=envir), ps=ps))
      if (is(all.str,"try-error"))
        all.str = as.character(all.str)
    } else {
      all.str = inner.rtutor.eval.to.string(expr.li, envir=envir)
    }
  }

  # convert special characters that cause JSON errors when shown in
  # HTML output or in ace console
  if (convert) {
    all.str = iconv(all.str, "LATIN2", "UTF-8")
    all.str = gsub("[\u0091\u0092]","'",all.str)

  }
  all.str
}

# this function performs evals and may be called inside eval.secure
inner.rtutor.eval.to.string = function(expr.li, envir) {
  all.str = NULL
  add = function(...) {
    str = paste0(..., collapse="\n")
    all.str <<- paste0(all.str,str, sep="\n")
  }
  i = 1
  for (i in seq_along(expr.li$expr)) {
    source = "Source was not parsed..."

    add("> ",paste0(expr.li$source[[i]], collapse="\n+ "))
    out = tryCatch(capture.output(eval(expr.li$expr[[i]], envir=envir)),
                   error = function(e) {
                     adapt.console.err.message(as.character(e))
                   })
    if (length(out)>0) {
      add(out)
    }
  }
  all.str    
}


eval.in.ace.console = function(code,envir=parent.frame(), consoleId, session) {
  restore.point("eval.in.ace.console")
  out = rtutor.eval.to.string(code,envir, convert=TRUE)

  #iconv(out,"UTF-8", "LATIN2")
  if (length(out)==0)
    out = ""

  #browser()
  # remove special characters that cause errors in ACE console

  tryCatch(updateAceEditor(session, consoleId, value=out,mode="r"),
           error = function(e) {message(e)}
  )
  #cat("\n ace console was successfuly updated!")
}


eval.in.console = function(code, envir=parent.frame()) {
  restore.point("eval.in.console")
  out = rtutor.eval.to.string(code,envir)
  cat(out)
}

is.last.chunk.of.ex = function(chunk.ind, ps=get.ps()) {
  ex.ind = ps$cdt$ex.ind[chunk.ind]
  chunk.ind == max(which(ps$cdt$ex.ind==ex.ind))
}

rerun.solved.chunks = function(ps = get.ps()) {
  inds = which(ps$cdt$is.solved)
  ok = TRUE
  for (chunk.ind in inds) {
    #cat("\n rerun chunk", chunk.ind)
    ps$chunk.ind = chunk.ind
    ps$stud.env = make.chunk.stud.env(chunk.ind, ps)
    if (is.null(ps$stud.env)) {
      stop(ps$failure.message)
    }
    ps$cdt[["stud.env"]][[chunk.ind]] <- ps$stud.env
    code = ps$cdt$stud.code[[chunk.ind]]

    if (!is.false(ps$catch.errors)) {
      ok = tryCatch({
        out <- rtutor.eval.to.string(code,ps$stud.env)
        TRUE
      }, error = function(e) {
        message(as.character(e))
        FALSE
      })
    } else {
      out <- rtutor.eval.to.string(code,ps$stud.env)
    }
    if (!ok)
      break
    if (is.last.chunk.of.ex(chunk.ind)) {
      ex.ind = ps$cdt$ex.ind[chunk.ind]
      ps$edt$ex.final.env[[ex.ind]] = list(copy.stud.env(ps$stud.env))
    }
  }
  # Could not rerun a chunk that was supposed to be solved
  # flag all later chunks as not solved
  if (!ok) {
    inds = which((1:NROW(ps$cdt$is.solved))>=chunk.ind)
    ps$cdt$is.solved[inds] = FALSE
  }
}

# Run all required previous shiny chunks
# needed to edit the current chunk
run.required.previous.shiny.chunks = function(ps = get.ps(),chunk.ind, update.chunk.ui=TRUE, use.sample.solution=isTRUE(ps$show.sample.solution)) {
  restore.point("run.previous.shiny.chunks")

  cdt = ps$cdt
  ck = cdt[chunk.ind,]
  nali = cdt$nali[[chunk.ind]]

  # Do we import from previous exercises?
  import.ex = names(ps$edt$import.var[[ck$ex.ind]])
  if (length(import.ex)>0) {
    edt = ps$edt
    ex.inds = unique(c(edt$ex.ind[match(ex.names,edt$ex.name)],ck$ex.ind))
  } else {
    ex.inds = ck$ex.ind
  }

  prev.chunk.inds = which(cdt$ex.ind %in% ck$ex.ind & cdt$chunk.ps.ind < (ck$chunk.ps.ind) & cdt$optional == FALSE & !cdt$is.solved)

  if (length(prev.chunk.inds)==0) {
    return(list(ok=TRUE))
  }
  ok = TRUE

  org.mode = ps$cdt$mode
  if (use.sample.solution) {
    org.code = ps$cdt$sol.txt
  } else {
    org.code = ps$cdt$stud.code
  }
  for (prev.chunk.ind in prev.chunk.inds) {
    # We change input if we set it to sample solution
    change.input = !identical(org.code[prev.chunk.ind], ps$cdt$stud.code[prev.chunk.ind])
    if (change.input) {
      ps$cdt$stud.code[[prev.chunk.ind]] = org.code[prev.chunk.ind]
      ok = check.shiny.chunk(chunk.ind = prev.chunk.ind, input.code=org.code[prev.chunk.ind])
    } else {
      if (org.mode[prev.chunk.ind] != "input") {
        ok = check.shiny.chunk(chunk.ind = prev.chunk.ind, input.code=org.code[prev.chunk.ind])
      } else {
        ok = check.shiny.chunk(chunk.ind = prev.chunk.ind)
      }
    }
    if (!ok) break
  }
  
  if (!ok) {
    res = list(ok=FALSE,failed.chunk=prev.chunk.ind)
    #ps$cdt$mode[prev.chunk.ind]=="input"
    #set.
  } else {
    res = list(ok=TRUE,failed.chunk=NULL)
  }
  return(res)
}


chunk.to.html = function(txt, chunk.ind, name=paste0("out_",ps$cdt$nali[[chunk.ind]]$name), ps = get.ps(), eval=TRUE, success.message=isTRUE(ps$cdt$is.solved[[chunk.ind]]), echo=TRUE, nali=NULL, quiet=TRUE) {
  restore.point("chunk.to.html")
  if (is.null(txt))
    return("")


  if (paste0(txt,collapse="\n") == "")
    txt = "# Press 'edit' to enter your code."

  if (isTRUE(ps$cdt$num.e[[chunk.ind]]>0)) {
    if (success.message) {
      add = c("# Great, solved correctly!")
      if (!is.null(ps$cdt$points) & isTRUE(ps$show.points)) {
        points = ps$cdt$points[[chunk.ind]]
        if (points==1) {
          add = paste0(add, " (1 point)")
        } else if (points>0) {
          add = paste0(add, " (",points, " points)")
        }
      }
      txt = c(add,txt)
    } else {
      txt = c("# Not yet solved...",txt)
      echo = TRUE
    }
  }
  opt = default.out.chunk.options()
  copt = ps$cdt$chunk.opt[[chunk.ind]]
  if (length(copt)>0) {
    opt[names(copt)] = copt
  }
  opt$eval = eval
  opt$echo = echo

  header = paste0("```{r '",name,"'",chunk.opt.list.to.string(opt,TRUE),"}")


  library(knitr)
  library(markdown)
  txt = c(header,sep.lines(txt),"```")

  #stop("stop in chunk.to.html")
  stud.env = ps$cdt[["stud.env"]][[chunk.ind]]
  #all.parent.env(stud.env)
  html ="Evaluation error!"


  if (isTRUE(ps$use.secure.eval)) {
    html = try(
      RTutor::rtutor.eval.secure(quote(
        knit.to.html(text=txt, envir=stud.env,fragment.only = TRUE,quiet = quiet)
      ), envir=environment())
    )
  } else {
    html = try(
      knit.to.html(text=txt, envir=stud.env,fragment.only = TRUE,quiet = quiet)
    )
  }
  
  if (is(html, "try-error")) {
    html = as.character(html)
  }
  restore.point("chunk.to.html.knit2html")

  # Add syntax highlightning
  if (!is.null(nali$chunkUI)) {
    html = paste0(paste0(html,collapse="\n"),"\n",
     "<script>$('#",nali$chunkUI," pre code').each(function(i, e) {hljs.highlightBlock(e)});</script>")
  }

  html
}

chunk.opt.list.to.string = function(li, add.comma=!TRUE) {
  if (length(li)==0)
    return("")
  is.char = sapply(li, is.character)
  quotes = ifelse(is.char,"'","")
  str = paste0(names(li),"=",quotes,li,quotes, collapse=", ")
  if (add.comma)
    str = paste0(", ", str)
  str
}
default.out.chunk.options = function() {
  list(fig.width=6.5, fig.height=4.5, fig.align='center', "warning"=FALSE, cache=FALSE, collapse=TRUE, comment=NA)
}

# Use local version of MathJax so that problem sets really run offline
mathJaxRTutor <- function(html, ps=get.ps()) {
  restore.point("mathJaxRTutor")

  if (isTRUE(ps$offline))
    return(html)

  return(withMathJax(html))
  
  # NOTE https://www.shinyapps.io/admin/#/login
  # does not work anymore!
  # 
  #path =  paste0(system.file('www', package='RTutor'),"/MathJax")
  #if (!file.exists(path))
  #path <- '//cdn.mathjax.org/mathjax/latest'

  #command = paste0(path, '/MathJax.js?config=TeX-AMS-MML_HTMLorMML')
  #path <- 'https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML'

  # tagList(
  # tags$head(
  # singleton(tags$script(src = command, type = 'text/javascript'))
  # ),
  # html,
  # tags$script(HTML('MathJax.Hub.Queue(["Typeset", MathJax.Hub]);'))
  # )
}

can.connect.to.MathJax = function() {
  return(TRUE)
  #library(RCurl)
  #url.exists("http://cdn.mathjax.org/mathjax/latest/MathJax.js")
 # url.exists("http://www.mathjax.org/")
}
