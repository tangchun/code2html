$path = ARGV[0]
if ($path == nil || !File.exists?($path))
	puts "Usage: code2html pathname"
	exit(-1)
end

$gid = 10000 #索引文件
$links = "" #目录树内容
$content = "" #代码生成的html内容
$file2gid = {} #文件名对应的gid，用目录树索引到html中的文件

#代码在html中必须转码，否则<之类不能显示
def html_escape(s)
    s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
end

def url_encode(s)
    s.to_s.gsub(/[^a-zA-Z0-9_\-.]/n){ sprintf("%%%02X", $&.unpack("C")[0]) }
end
 
#目录树类,这个还用到全局变量到时候要改改 
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
		write_node_inner(pid, $path, $path, @tree[$path])
	end

	def write_node_inner(pid,  fullpath, pname, tr)
	  link_gid = $file2gid[fullpath]
		#puts "#{fullpath}: #{link_gid}"
		if (link_gid == nil)
			$links += ("d.add(#{@cid}, #{pid}, \"#{pname}\", \"\")\n")
		else
			$links +=("d.add(#{@cid}, #{pid}, \"#{pname}\", \"javascript:open_file(#{link_gid});\")\n")
		end

		pid = @cid
		if (tr.size() > 0)
			tr.each {|k,v|
        @cid = @cid + 1
				#puts("d.add(#{@cid}, #{pid}, \"#{k}\", \"\")")
				filepath = fullpath.length() > 0 ? fullpath + "/" + k : k
				write_node_inner(pid, filepath, k, v) 
			}
		end
	end	
end


# gen a path tree
$t = Tree.new("#{$path}")
def parse_to_tree(f)
	 $t.add(f.split("/"))
end



def handle(fname)
  parse_to_tree(fname) # 生成目录树
	if (!File.file?(fname))
		return
	end

	$gid = $gid + 1
	#$links += "d.add(#{$gid}, 0, \"#{fname}\", \"javascript:open_file(#{$gid});\")\n"
	$file2gid[fname] = $gid
	
	c = File.read(fname)
	pre_class = ""
	if ($gid == 10001)
		pre_class = "class=\"prettyprint\""
	end
	
	$content += %Q{
	<div class="code" id="#{$gid}" style="margin:0px 0px 0px 0px; display:none;z-index:8">
  <pre #{pre_class} id="#{$gid+100000}">
#{html_escape(c)}
	</pre>	
	</div>
	}
		
end


Dir.glob("#{$path}/**/*"){|f|
	handle(f)
}

# put out result ...........
$f_result = File.open("#{$path}_project.html", "w")

$t.write_node()
$html = File.read("template.html").each_line{|l|
	if (l.include?("9e62INDEX"))
		$f_result.puts $links
	elsif (l.include?("9e62FILECONTENT"))
		$f_result.puts $content
	else
	  $f_result.puts l
  end
}
$f_result.close()



