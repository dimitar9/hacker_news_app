import nltk
from nltk.corpus import stopwords

class ExtractKW(object):
    def __init__(self):
        self.classname = "ExtractKW"


        # Used when tokenizing words
        self.sentence_re = r'''(?x)      # set flag to allow verbose regexps
            ([A-Z])(\.[A-Z])+\.?  # abbreviations, e.g. U.S.A.
            | \w+(-\w+)*            # words with optional internal hyphens
            | \$?\d+(\.\d+)?%?      # currency and percentages, e.g. $12.40, 82%
            | \.\.\.                # ellipsis
            | [][.,;"'?():-_`]      # these are separate tokens
        '''

        self.lemmatizer = nltk.WordNetLemmatizer()
        self.stemmer = nltk.stem.porter.PorterStemmer()

        #Taken from Su Nam Kim Paper...
        grammar = r"""
            NBAR:
                {<NN.*|JJ>*<NN.*>}  # Nouns and Adjectives, terminated with Nouns
            
            NP:
                {<NBAR>}
                {<NBAR><IN><NBAR>}  # Above, connected with in/of/etc...
        """
        self.chunker = nltk.RegexpParser(grammar)


    def leaves(self,tree):
        """Finds NP (nounphrase) leaf nodes of a chunk tree."""
        for subtree in tree.subtrees(filter = lambda t: t.node=='NP'):
            yield subtree.leaves()

    def normalise(self,word):
        """Normalises words to lowercase and stems and lemmatizes it."""
        word = word.lower()
        word = self.stemmer.stem_word(word)
        word = self.lemmatizer.lemmatize(word)
        return word

    def acceptable_word(self,word):
        """Checks conditions for acceptable word: length, stopword."""
        accepted = bool(2 <= len(word) <= 40
            and word.lower() not in stopwords.words('english'))
        return accepted


    def get_terms(self,tree):
        for leaf in self.leaves(tree):
            term = [ self.normalise(w) for w,t in leaf if self.acceptable_word(w) ]
            yield term

    def get_keywords(self,text):
        


        toks = nltk.regexp_tokenize(text, self.sentence_re)
        postoks = nltk.tag.pos_tag(toks)

        print postoks

        tree = self.chunker.parse(postoks)
        
        
        terms = self.get_terms(tree)
        result_list = []
        for term in terms:
            for word in term:
                print word
                result_list.append(word)

        print result_list
        return(result_list)

    