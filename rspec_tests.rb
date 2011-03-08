# copyright 2011 Mike Stipicevic / Nascent Development Corporation
# see README/LICENSE for details

def spawnprog(prog,args)
  read, write = IO.pipe
  rstderr, wstderr = IO.pipe
  pid = fork {
    $stdout.reopen write
    $stderr.reopen wstderr
    read.close
    rstderr.close
    exec(prog, *args)
  }
  write.close
  wstderr.close
  lines = read.map {|x| x.chomp}
  errlines = rstderr.map {|x| x.chomp}
  Process.waitpid(pid)
  {:status=> $?.exitstatus, :stdout=> lines, :stderr=> errlines}
end

# if your program is in the current directory,
# make sure to put ./ in front (i.e. './a.out')
progname = 'echo'

describe progname do
  context "when no arguments are given" do
    it "should return success" do
      spawnprog(progname, [])[:status].to_i.should == 0
    end

    it "should not return anything on stderr" do
      spawnprog(progname, [])[:stderr].should == []
    end

    it "should emit a blank line on stdout" do
      spawnprog(progname, [])[:stdout].should == [""]
    end
  end

  context "when given a single argument" do
    arguments = ["test"]
    it "should return success" do
      spawnprog(progname, arguments)[:status].to_i.should == 0
    end

    it "should not return anything on stderr" do
      spawnprog(progname, arguments)[:stderr].should == []
    end

    it "should emit a single line with the argument" do
      spawnprog(progname, arguments)[:stdout].should == arguments
    end
  end


  context "when given two arguments" do
    arguments = ["test","test2"]
    it "should return success" do
      spawnprog(progname, arguments)[:status].to_i.should == 0
    end

    it "should not return anything on stderr" do
      spawnprog(progname, arguments)[:stderr].should == []
    end

    it "should emit a single line with the arguments separated by a space" do
      spawnprog(progname, arguments)[:stdout].should == [arguments.join(" ")]
    end
  end
end
