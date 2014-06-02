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
  field :nonlinearity_value, type: Array
  field :SAC_value, type: Array
  private

  def nonlinearity
    self.body=""
    bytes_array=Array.new

    funkcje=Array.new(8) {|e| e=Array.new}
    funkcje_podstawowe=Array.new(8) {|e| e=Array.new}
    funkcje_liniowe=Array.new
    nieliniowosc=Array.new(8) {|e| e=1000}
    sac_tablica=Array.new(8)
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
      v=1
      count=0
      256.times do |counter|
        funkcje_podstawowe[i][counter]=v
        count+=1
        (v==0 ? v=1 : v=0 and count=0) if count >= 2**(i)
      end
      
    end

    8.times do |i|
      j=i+1
      combinations=funkcje_podstawowe.combination(j).to_a
      wynik=Array.new(256) { |f| f=0  }
      
      combinations.each { |e| e.each{|f| wynik=xor(wynik,f)} and funkcje_liniowe.push(wynik) }
    end

    8.times do |i|
      funkcje_liniowe.size.times do |counter| 
        nl=xor_difference(funkcje_liniowe[counter],funkcje[i])
        nieliniowosc[i]=nl if nl<nieliniowosc[i]
      end
    end

    funkcje.size.times do |i|
      sac_tablica[i]=SAC(funkcje[i])
    end

    self.function=funkcje
    self.function_basic=funkcje_podstawowe
    self.function_linear=funkcje_liniowe
    self.nonlinearity_value=nieliniowosc
    self.SAC_value=sac_tablica
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

  def xor_difference (f1,f2)
    count=0
    if f1.size == f2.size
      f1.size.times do |i|
        count+=1 unless f1[i]==f2[i]
      end
      return count
    else
    return 0
    end
  end

  def SAC (fnc)
    sac_vl=0
    arg_count=Math.log(fnc.size, 2)
    arg_count.to_i.times do |mask|
      tmp=0
      masked_function=Array.new(fnc.size)    
      fnc.size.times do |i|
        masked_function[i^(2**mask)]=fnc[i]
      end
      fnc.size.times do |i|
        tmp+=1 unless fnc[i]==masked_function[i]
      end
      sac_vl+=tmp
    end
    Rails.logger.debug "Show this message!"+sac_vl.to_s
    return sac_vl/(arg_count)/fnc.size
  end

end
