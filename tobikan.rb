#coding:utf-8

require 'mechanize'

base_url = "http://www.tobikan.jp"

agent = Mechanize.new()

page = agent.get(base_url + "/exhibition/index.html")

page.search('//*[@id="page"]/div[6]/div/div[3]/a').each do |e|
	
	exhibition = {}
	exhibition['title'] = e.text
	exhibition['url'] = base_url + e['href']

	detail_page = agent.get(base_url + e['href'])

	page = detail_page.search('//*[@id="page"]/div[9]/div/div')

	if page.text.match(/^会期.*?/)

		first_half_date_match = page.text.match(/^【前期】.*?(\d{4}年\d{1,2}月\d{1,2}日).*?(?:〜|～).*?((\d{4}年|)(\d{1,2}月|)\d{1,2}日).*?/)
		second_half_date_match = page.text.match(/^【後期】.*?(\d{4}年\d{1,2}月\d{1,2}日).*?(?:〜|～).*?((\d{4}年|)(\d{1,2}月|)\d{1,2}日).*?/)
		

		exhibition['date_begin_1'] =  DateTime.strptime(first_half_date_match[1], "%Y年%m月%d日")
	 	exhibition['date_end_1'] = DateTime.strptime(first_half_date_match[2], "%m月%d日")
	 	exhibition['date_begin_2'] =  DateTime.strptime(second_half_date_match[1], "%Y年%m月%d日")
	 	exhibition['date_end_2'] = DateTime.strptime(second_half_date_match[2], "%m月%d日")
	else
		page = detail_page.search('//*[@id="page"]/div[10]/div/div')

		date_match = page.text.match(/^会期.*?(\d{4}年\d{1,2}月\d{1,2}日).*?(?:〜|～).*?((\d{4}年|)(\d{1,2}月|)\d{1,2}日).*?/)

		exhibition['date_begin'] =  DateTime.strptime(date_match[1], "%Y年%m月%d日")
		exhibition['date_end'] = DateTime.strptime(date_match[2], "%Y年%m月%d日")
	end

 	exhibition['images'] = []
 	detail_page.search('//*[@id="page"]//img').each do |img|

 		exhibition['images'].push({"title" => img['alt'], "url" => base_url + img['src']})
 	end
 	pp exhibition
 end