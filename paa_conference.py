from lxml import html
import requests
import os
import codecs

link_part1 = "http://paa"
link_part2 = ".princeton.edu/sessions/"
os.chdir('/home/valeire/git_repos/gendered_authorship')
    
f = codecs.open('paa_conference.txt', 'w', 'utf-8')
f.write('title\tauthor1_firstn\tauthor1_name\tauthor2_firstn\tauthor2_name\tauthor3_firstn\tauthor3_name\tauthor4_firstn\tauthor4_name\tauthor5_firstn\tauthor5_name\tauthor6_firstn\tauthor6_name')

for i in range(2002, 2003):
    for j in range(1, 3):
        link = link_part1 + str(i) + link_part2 + str(j)
        print link
        page = requests.get(link)
        tree = html.fromstring(page.text)
        papers = tree.xpath('//li/p')
        for k in papers:
            paper_title = k.xpath('a')
            paper_authors = k.xpath('span')
            title = paper_title[0].text
            f.write('\n'+title)
            for l in paper_authors:
                author = l.text.split(' ',1)
                author_firstn = author[0]
                author_lastn =  author[1] 
                f.write('\t'+author_firstn+'\t'+author_lastn)
          

f.close()
        

                        
