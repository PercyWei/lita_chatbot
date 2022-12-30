# -*- coding:utf-8 -*-
$operator=Array[2]
$operator[0]=%w[+ - * /]
$operator[1]=%w[( )]
$digit_reg=/(?:(?<=\D)-)?\d+(?:\.\d+)?/
$ope_reg=/ \+ | \- | \* | \/ | \( | \) /x
$ope_method={}
$ope_method["+"]=lambda{|x,y| x+y}
$ope_method["-"]=lambda{|x,y| x-y}
$ope_method["*"]=lambda{|x,y| x*y}
$ope_method["/"]=lambda{|x,y| x/y}
module Lita
  module Handlers
    # class Doubler < Handler
    #   # insert handler code here
    #   route(
    #     /^double\s+(\d+)$/i,
    #     :respond_with_double,
    #     command: true,
    #     help: { 'double N' => 'prints N + N'}
    #   )

    #   def respond_with_double(response)
    #     n = response.match_data.captures.first
    #     n = Integer(n)

    #     response.reply "#{n} + #{n} = #{double_number n}"
    #   end
      
    #   def double_number(n)
    #     n + n
    #   end

    #   Lita.register_handler(self)
    # end
    
    class Doubler < Handler
      route(
	        /^cal\s+.*/i,
          :respond_answer,
	        command:true,
	        help: { 'cal a+b' => 'prints c'}
          )
      
      def respond_answer(response)
        get=response.match_data
        get_s=get.to_s.sub(/cal /, "")
        instr=" "+get_s
        inarr=split_num_ope instr
        suf=infix_to_suffix inarr
        ans=comput_suffix suf
        
        response.reply "#{get_s} = #{ans}"
      end

      def infix_to_suffix arr
        s1,s2=[],[] #stack
        arr.each do |x|
          if x =~$digit_reg
            s2.push format("%.2f",x).to_f
          else
            if $operator[0].include? x
              if s1.size==0 or
                s1[-1]==$operator[1][0] or ($operator[0].index x) > ($operator[0].index s1[-1]) then
                  s1.push x
                else
                    s2.push s1.pop
                    redo
                end
              elsif $operator[1].include? x
                if x==$operator[1][0]
                  s1.push x
                else
                  s2.push s1.pop until s1.size==0 || s1[-1]==$operator[1][0]
                  if s1.size==0
                    puts "error: bracket is not match\n"
                    exit
                  else
                    s1.pop
                  end
                end
              else
                puts "error: input symbol\n"
                exit
              end
            end
          end
        while s1.size !=0
          s2.push s1.pop
        end
        s2
      end

      def comput_suffix arr
        s_num=[] #also a stack
        arr.each do |x|
          if x.class == Float
            s_num.push x
          elsif s_num.size>=2
            a,b=s_num.pop,s_num.pop
            r=$ope_method[x].call b,a
            # puts "#{b} #{x} #{a} = #{r}"
            s_num.push r
          else
            break
          end
        end
        if s_num.size!=1
          puts "error: the equ is not true\n"
          exit
        end
        format("%.2f", s_num[0] ).to_f
      end

      def split_num_ope str
          outarr=[]
          define_singleton_method :handle_ope_str do |str|
              while(str=~$ope_reg)
                  outarr.push $&
                  str=$'
              end
          end
          while(str=~$digit_reg)
              pre,now,nxt=$`,$&,$'
              handle_ope_str pre.strip unless pre.nil? or pre.strip==""
              outarr.push now
              str=nxt
          end
          handle_ope_str str.strip unless str.nil? or str.strip==""
          # p outarr
          outarr
      end

      Lita.register_handler(self)
    end

  end
end
