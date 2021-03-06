#coding:utf-8

require 'mechanize'
require 'redis'

base_url = "http://www.tobikan.jp"

agent = Mechanize.new()

page = agent.get(base_url + "/exhibition/index.html")

result = []
page.search("//*[@class='label border mb5']/a").each do |e|
	exhibition = {}
	exhibition['title'] = e.text
	exhibition['url'] = base_url + e['href']

	detail_page = agent.get(base_url + e['href'])

	page = detail_page.search('//*[@id="page"]/div[9]/div/div')
	p "page.text:#{page.text}"

	if page.text.match(/^会期.*?/) && page.text.match(/.*?前期.*?/) && page.text.match(/.*?後期.*?/)

		first_half_date_match = page.text.match(/^【前期】.*?(\d{4}年\d{1,2}月\d{1,2}日).*?(?:〜|～).*?((\d{4}年|)(\d{1,2}月|)\d{1,2}日).*?/)
		second_half_date_match = page.text.match(/^【後期】.*?(\d{4}年\d{1,2}月\d{1,2}日).*?(?:〜|～).*?((\d{4}年|)(\d{1,2}月|)\d{1,2}日).*?/)
		p "first:#{first_half_date_match}"
		p "second:#{second_half_date_match}"
		# 展示会に対して日程 多のモデルにする　スケジュールっていう配列にする
		exhibition['date_begin_1'] =  DateTime.strptime(first_half_date_match[1], "%Y年%m月%d日")
	 	exhibition['date_end_1'] = DateTime.strptime(first_half_date_match[2], "%m月%d日")
	 	exhibition['date_begin_2'] =  DateTime.strptime(second_half_date_match[1], "%Y年%m月%d日")
	 	exhibition['date_end_2'] = DateTime.strptime(second_half_date_match[2], "%m月%d日")
	else
		page = detail_page.search("//*[@class='part r13 table']/div[2]/div")
		p page.text
		from_to = []
		temp = page.text.split(%r{[〜|～]})
		temp.each do |date|
			begin
				from_to << DateTime.strptime(date.strip, "%Y年%m月%d日")
			rescue ArgumentError
				from_to << DateTime.strptime(date.strip, "%m月%d日")
			end
		end
		# 配列の１件目がfrom2件目がto。。。配列に入ってる。データ構造は今後見直し。
		from_to.each { |d| p "#{d.year}-#{d.month}-#{d.day}" }

		#date_match = page.text.match(/^会期.*?(\d{4}年\d{1,2}月\d{1,2}日).*?(?:〜|～).*?((\d{4}年|)(\d{1,2}月|)\d{1,2}日).*?/)
		
		exhibition['date_begin'] = from_to[0] # 開始日  #DateTime.strptime(date_match[1], "%Y年%m月%d日")
		exhibition['date_end']   = from_to[1] # 終了日  #DateTime.strptime(date_match[2], "%Y年%m月%d日")
	end

 	exhibition['images'] = []
 	detail_page.search('//*[@id="page"]//img').each do |img|

 		exhibition['images'].push({"title" => img['alt'], "url" => base_url + img['src']})
 	end
	
	p "（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）"
	p exhibition
	p "（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）（・(エ)・）"

	result << exhibition
 end

p "CoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCo"
result.each {|r| p r; p "=========================="; }
p "CoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCoCo"
#redis = Redis.new(:host => "153.149.7.62")
redis = Redis.new(:host => "127.0.0.1")
redis.set("tobikan", Marshal.dump(result))
