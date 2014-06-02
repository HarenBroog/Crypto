class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :nonlinearity
  
  mount_uploader :sbox, SboxUploader

  field :name, type: String
  field :body, type: String
  field :function, type: Array
  field :function_basic, type: Array
  field :function_linear, type: Array
  private

  def nonlinearity
    self.body=""
    bytes_array=Array.new

    funkcje=Array.new(8) {|e| e=Array.new}
    funkcje_podstawowe=Array.new(8) {|e| e=Array.new}
    funkcje_liniowe=Array.new(8) {|e| e=Array.new}
    text=IO.binread(self.sbox.current_path)

    text.bytes.each { |e| bytes_array.push(e)  }
    bytes_array.reject!.each_with_index { |str, i| i.odd? }



    bytes_array.each { 
        |e|
        e.size.times do |counter|
          funkcje[counter].push(e[counter])
        end 
      }

    8.times do |i|
      v=0
      count=0
      256.times do |counter|
        funkcje_podstawowe[i][counter]=v
        count+=1
        v==0 ? v=1 : v=0 and count=0 if count >= 2**(i+1)
      end
    end

    8.times do |i|
      j=i+1
      combinations=funkcje_podstawowe.combination(j).to_a
      wynik=Array.new(256) { |i| i=0  }

      combinations.each { |e| j==1 ? funkcje_liniowe.push(e[0]) : e.each{|f| wynik=xor(wynik,f) and funkcje_liniowe.push(wynik) }}
    end

    self.function=funkcje
    self.function_basic=funkcje_podstawowe
    self.function_linear=funkcje_liniowe
    funkcje.each { |e| e.each { |f| self.body+=to_bool(f).to_s  } and self.body+="\n"  }  
  end

  def to_bool num
    return true if num == 1
    return false if num == 0
  end

  def xor (f1,f2)
    if f1.size == f2.size
      wynik=Array.new(f1.size) { |i| i=0 }

      f1.size.times do |i|
        f1[i]==f2[i] ? wynik[i]=0 : wynik[i]=1
      end
      return wynik
    else
    return nil
    end
  end
end
