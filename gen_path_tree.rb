=begin
[a/b/c/e.c]
[a/b/f.c]
a 1
b 2
c 3
b->parent = 1
c->parent = 2
a->parent = 0
e.c ->parent = 3
f.c ->parent = 2

a/b/c
a/b/d
a/c/d

a-b-c
 | -d
 -c-d
 
curr_parentid
curr_id
=end


def print_path(f)
	if (File.directory?(f))
		puts  ("#{f}: path: #{File.path(f)}, filename: ")
	else
	  puts  ("#{f}: path: #{File.path(f)}, file: #{File.basename(f)}")
	end
	
	#p f.split(/[\\\/]/)
end

$id = -1
$path2id = {}
$f2parentid={}
$f2id = {}


def create_node(f)
   v = File.split(f)
   $id = $id + 1
   myid = $id
	 $path2id[f] = myid
	 parentid = get_parentid(v[0]) 
	 $f2parentid[f] = 
	 puts("d.add(#{myid}, #{parentid}, \"#{v[1]}\", \"#{f}\")")
	 return myid;
end

def get_parentid(f)
	pid = $path2id[f]
	if (pid != nil)
		return pid
	else
		return create_node(f)
	end
end


def handle_path(f)
	create_node(f)
end

class Tree
	def initialize(root)
		@tree = {}
		@tree[root] = {}
	end

	def add(v)
		pcur = @tree
		v.each { |f|
			if (pcur[f] == nil)
				pcur[f] = {}
			end
			pcur = pcur[f]
		}
	end

	def print()
		p @tree
	end

	def dump()
		dump_tree("", @tree)
	end

	def dump_tree(p, tr)
		if (tr.size() > 0)
			tr.each {|k,v|
				dump_tree(p + "/" + k   , v)
			}
		else
			puts p
		end
	end

	def write_node()
		pid = -1
		@cid = 0
		write_node_inner(pid, "project", @tree)
	end

	def write_node_inner(pid,  pname, tr)
		if (tr.size() > 0)
			puts("d.add(#{@cid}, #{pid}, \"#{pname}\", \"\")")
		else
			puts("d.add(#{@cid}, #{pid}, \"#{pname}\", \"javascript:open_file(#{@cid + 10000});\")")
		end

		pid = @cid
		if (tr.size() > 0)
			tr.each {|k,v|
                                @cid = @cid + 1
				#puts("d.add(#{@cid}, #{pid}, \"#{k}\", \"\")")
				write_node_inner(pid, k, v) 
			}
		end
	end

	
end

# gen a path tree
$t = Tree.new("a")
def parse_to_tree(f)
	 $t.add(f.split("/"))
end


Dir.glob("a/**/*") {|f|	
	parse_to_tree(f)
}
#$t.print()
#$t.dump()
$t.write_node()


