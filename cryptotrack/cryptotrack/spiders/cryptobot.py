import scrapy
import urllib.parse
import socket
from scrapy.http import Request
from cryptotrack.items import CryptotrackItem
from scrapy.loader.processors import MapCompose
from scrapy.loader import ItemLoader


class CryptobotSpider(scrapy.Spider):
    name = 'cryptobot'
    allowed_domains = ['coinmarketcap.com']
    start_urls = ['https://coinmarketcap.com/coins/views/all/']

    def parse(self, response):
        item_selector = response.xpath('//a[@class="currency-name-container"]/@href')
        for url in item_selector.extract():
            yield Request(urllib.parse.urljoin(response.url, url), callback=self.parse_item)


    def parse_item(self, response):
        l = ItemLoader(item=CryptotrackItem(), response=response)

        l.add_xpath('Short_name', '//img[contains(@class, "currency-logo")]/following-sibling::small[1]/text()', re='[A-Z]+')
        l.add_xpath('Exact_name', '//img[contains(@class, "currency-logo")]/ancestor::h1/text()[4]', MapCompose(str.strip, str.title))
        l.add_xpath('Today_rate', '/descendant::span[@data-currency-value=""][1]/text()', MapCompose(lambda i: i.replace(',', '')), re='[,.0-9]+')
        l.add_xpath('Market_cap', '/descendant::span[@data-currency-value=""][2]/text()', MapCompose(lambda i: i.replace(',', '')), re='[,.0-9]+')
        l.add_xpath('Today_rank', '//span[@class="label label-success"]/text()', re='[.0-9]+')

        return l.load_item()