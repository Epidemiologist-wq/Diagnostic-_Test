###############################################################################
# MATH515 Health Data and Medical Statistics
# Session 2 - Diagnostic tests, binomial and Poisson distributions
#
# What is in this script:
#   Part 1. Diagnostic tests (sensitivity, specificity, predictive values)
#   Part 2. Bayes, likelihood ratios and ROC curves
#   Part 3. The binomial distribution
#   Part 4. The Poisson distribution
#   Part 5. Binomial or Poisson?
#
# How to use this script:
#   - Run it one section at a time. Ctrl + Enter runs the line your cursor is
#     on. Ctrl + Shift + Enter runs the whole file.
#   - Leave the `#` lines in place. They are your revision notes.
#   - Every plot in this script is followed by a "WHAT THIS PLOT TELLS US"
#     paragraph. If you are short of time, read the code, look at the picture,
#     then read that paragraph.
#
# R basics you need for this file:
#   -  <-   means "store this in". x <- 5 puts the number 5 into x.
#   -  #    means "comment". R ignores everything after it on that line.
#   - "text" in quotes is a label, not a number. R treats it as text.
#   - c(1, 2, 3) builds a list of values. c() stands for "combine".
#   - a:b  builds the whole numbers from a to b, so 0:4 is 0, 1, 2, 3, 4.
###############################################################################


################################################################################
# PART 1. DIAGNOSTIC TESTS
################################################################################

# ---------------------------------------------------------------------------
# 1.1  The heart-failure numbers, and why the four counts matter
# ---------------------------------------------------------------------------
# We start with the heart-failure example from the lecture. Four counts were
# recorded. Two describe the test result and two describe the true diagnosis.
#
# The naming is worth pausing on. "Positive" means the test says the disease is
# there. "True" means that answer matches the real diagnosis. So:
#
#   true_positive  - the test said yes, and the person really does have it
#   false_positive - the test said yes, but the person does NOT have it
#   false_negative - the test said no, but the person DOES have it
#   true_negative  - the test said no, and the person really does not have it
#
# Two nicknames are worth holding on to. A false positive is a false ALARM: you
# told someone they were ill when they were not. A false negative is a MISS: the
# disease was there and you let it go. Alarms and misses are the two ways a test
# can fail, and almost everything in Part 1 is about the trade-off between them.

true_positive  <- 35
false_positive <- 7
false_negative <- 68
true_negative  <- 300

# A data.frame() is a table. It was introduced in Practical 1. We build one so
# the four counts can be seen side by side.
#
# Each argument below is one column, and each column is built with c(...). Every
# column must hold the same number of entries, which here is two.

heart_failure_table <- data.frame(
  test_result     = c("Positive", "Negative"),
  disease_present = c(true_positive, false_negative),
  disease_absent  = c(false_positive, true_negative)
)

# Typing the name on its own prints the table.

heart_failure_table

# Look at the two columns rather than the two rows. Down the "disease_present"
# column there are 35 + 68 = 103 people, all of whom really have heart failure.
# Down the "disease_absent" column there are 7 + 300 = 307 people, none of whom
# do. Those two totals are the denominators for sensitivity and specificity, and
# keeping them in view explains every formula in this part.


# ---------------------------------------------------------------------------
# 1.2  Sensitivity - "does the test catch the people who are ill?"
# ---------------------------------------------------------------------------
# Sensitivity asks one narrow question: among the people who really have the
# disease, what fraction did the test pick up?
#
# Because the question is only about people who have the disease, the bottom of
# the fraction counts only people with the disease. That is true_positive plus
# false_negative - everyone in the "disease_present" column, whether or not the
# test spotted them.
#
#               true_positive                      35
#   sensitivity = ------------------------  =  -----------  =  0.340
#               true_positive + false_negative    35 + 68
#
# In words: this test finds about 34% of the people who have heart failure. The
# other 66% are missed. That is a poor sensitivity, and in a clinical setting
# that is the number that decides whether you can trust a negative result.

sensitivity <- true_positive / (true_positive + false_negative)

sensitivity
round(sensitivity, 3)   # round(x, 3) keeps three decimal places


# ---------------------------------------------------------------------------
# 1.3  Specificity - "does the test leave healthy people alone?"
# ---------------------------------------------------------------------------
# Specificity asks the mirror question: among the people who do NOT have the
# disease, what fraction did the test correctly clear?
#
# Only people without the disease are in the bottom of the fraction. That is
# false_positive plus true_negative.
#
#               true_negative                      300
#   specificity = ------------------------  =  -----------  =  0.977
#               false_positive + true_negative    7 + 300
#
# In words: about 98% of the healthy people are correctly cleared. Only about 2%
# get a false alarm. That is a very good specificity.
#
# Notice the pattern: sensitivity and specificity are both calculated WITHIN a
# group that is already known by diagnosis. That is the key idea, and it comes
# back in Part 2 when we ask what a result means for one patient.

specificity <- true_negative / (false_positive + true_negative)

specificity
round(specificity, 3)


# ---------------------------------------------------------------------------
# EXERCISE 1 - Positive and negative predictive value
# ---------------------------------------------------------------------------
# The predictive values turn the conditioning around. Instead of starting from
# the true diagnosis, they start from the TEST RESULT.
#
# Positive predictive value (PPV): among everyone who tested positive, what
# fraction really have the disease?
#
#               true_positive                       35
#   PPV = ------------------------  =  -----------  =  0.833
#               true_positive + false_positive     35 + 7
#
# Negative predictive value (NPV): among everyone who tested negative, what
# fraction really are disease-free?
#
#               true_negative                       300
#   NPV = ------------------------  =  -----------  =  0.815
#               true_negative + false_negative     300 + 68
#
# This is exactly what a patient wants to know. After a result comes back, the
# question is not "how good is the test in general?" but "what does this result
# mean for me?"
#
# A neat way to see the difference: sensitivity reads down the DISEASE column
# and asks "of the ill, how many tested positive?". PPV reads down the TEST
# column and asks "of those who tested positive, how many are ill?". Same two
# numbers in the top of the fraction, different bottom. The bottom is the whole
# difference, and it is where mistakes happen.

positive_predictive_value <- true_positive / (true_positive + false_positive)
negative_predictive_value <- true_negative / (true_negative + false_negative)

positive_predictive_value
negative_predictive_value
round(positive_predictive_value, 3)
round(negative_predictive_value, 3)

# Why is PPV as high as 0.83 when sensitivity is only 0.34? Because this dataset
# was assembled in a clinic and is full of people with heart failure (103 out of
# 410). When disease is common in the group being tested, a positive result is
# usually right even if the test misses a lot of cases. Part 2 shows what happens
# when that stops being true.

# For completeness, here are all four ratios together. Save this as a reference
# card - if you can reproduce this list from memory you have Part 1.

#   sensitivity = TP / (TP + FN)   of the ill, how many tested positive
#   specificity = TN / (TN + FP)   of the well, how many tested negative
#   PPV         = TP / (TP + FP)   of positives, how many are ill
#   NPV         = TN / (TN + FN)   of negatives, how many are well


# ---------------------------------------------------------------------------
# 1.4  The appendicitis example
# ---------------------------------------------------------------------------
# Now the appendicitis exercise from the lecture. Picture 100 patients: 30 have
# appendicitis and 70 do not. The test is a high temperature.
#
# Here we are given the test's properties rather than raw counts:
#   - sensitivity 0.70  -> 70% of those with appendicitis have a temperature
#   - 0.40 of those WITHOUT appendicitis also have a temperature
#
# That second number, 0.40, is the false positive rate. Specificity is
# 1 - 0.40 = 0.60. Working in counts rather than proportions lets us display a
# table, and it makes the arithmetic easier to follow.

appendicitis_present <- 30
appendicitis_absent  <- 70

# Split each group into the part the test catches and the part it misses.

appendicitis_true_positive  <- 0.70 * appendicitis_present
appendicitis_false_negative <- appendicitis_present - appendicitis_true_positive
appendicitis_false_positive <- 0.40 * appendicitis_absent
appendicitis_true_negative  <- appendicitis_absent - appendicitis_false_positive

appendicitis_table <- data.frame(
  temperature     = c("Above 37.5", "37.5 or below"),
  appendicitis    = c(appendicitis_true_positive, appendicitis_false_negative),
  no_appendicitis = c(appendicitis_false_positive, appendicitis_true_negative)
)

appendicitis_table


# ---------------------------------------------------------------------------
# EXERCISE 2 - Sensitivity, specificity and PPV for the temperature test
# ---------------------------------------------------------------------------
# Same three fractions as before, applied to the new counts.

appendicitis_sensitivity <- appendicitis_true_positive /
  (appendicitis_true_positive + appendicitis_false_negative)

appendicitis_specificity <- appendicitis_true_negative /
  (appendicitis_true_negative + appendicitis_false_positive)

appendicitis_ppv <- appendicitis_true_positive /
  (appendicitis_true_positive + appendicitis_false_positive)

round(appendicitis_sensitivity, 3)   # 0.700 - given in the question
round(appendicitis_specificity, 3)   # 0.600 - 1 minus the given 0.40
round(appendicitis_ppv, 3)           # 0.429 - new information

# Sensitivity and specificity must come back as the values we started with. They
# were inputs, so they cannot contain any surprise. The PPV is the one new
# number, and it depends entirely on how common appendicitis is in this group of
# 100.
#
# Compare its value of about 0.43 with the heart-failure PPV of 0.83. Same kind
# of arithmetic, very different answers - the case mix is doing the work.


################################################################################
# PART 2. BAYES, LIKELIHOOD RATIOS AND ROC CURVES
################################################################################

# ---------------------------------------------------------------------------
# 2.1  Probability and odds: the pre-test probability
# ---------------------------------------------------------------------------
# Probability and odds are two ways of writing the same information.
#
#   probability p  ->  odds = p / (1 - p)
#   odds o         ->  probability = o / (1 + o)
#
# If the probability is 0.75, the odds are 0.75 / 0.25 = 3, often written "3 to
# 1". The two are interchangeable. Odds are used here purely because Bayes'
# theorem becomes a single multiplication when written in odds form, which makes
# it far easier to use at the bedside.
#
# PRE-TEST PROBABILITY is the chance that the patient has the disease BEFORE you
# see the test result. It is your clinical starting point, based on symptoms,
# history, examination and how common the disease is in the people you see.
#
# The proportion with disease in this dataset is 103 / 410. The lecture made the
# point that this is NOT the prevalence of heart failure in the general
# population. It is the proportion inside a sample assembled because these
# patients were already being investigated. That distinction matters, and Part
# 2's Exercise 3 shows why.

pre_test_probability <- (true_positive + false_negative) /
  (true_positive + false_negative + false_positive + true_negative)

pre_test_odds <- pre_test_probability / (1 - pre_test_probability)

pre_test_probability   # about 0.251 - one quarter of this sample has disease
pre_test_odds          # about 0.336


# ---------------------------------------------------------------------------
# 2.2  The likelihood ratio
# ---------------------------------------------------------------------------
# The positive likelihood ratio packs sensitivity and specificity into a single
# number. It answers: "if this result comes back positive, how many times more
# likely is it in a person with the disease than in a person without it?"
#
#   LR+ = sensitivity / (1 - specificity)
#
# The top is the chance of testing positive if you HAVE the disease. The bottom
# is the chance of testing positive if you do NOT. Both describe the test, and
# neither mentions how common the disease is.
#
#   LR+ = 1     the result tells you nothing at all
#   LR+ > 1     the result raises the odds of disease
#   LR+ near 2  a small shift
#   LR+ > 10    a large and often conclusive shift
#
# There is a negative version too, LR- = (1 - sensitivity) / specificity, which
# describes how much a NEGATIVE result lowers the odds. This script only uses
# LR+, because the worked example follows a positive result, but the idea is
# symmetric.
#
# The big advantage of a likelihood ratio over PPV is portability. PPV is welded
# to the population it was measured in. LR+ describes the test itself and can be
# carried from one setting to another. That is why textbooks print LR+ values
# and let you supply your own pre-test probability.

lr_positive <- sensitivity / (1 - specificity)
lr_positive   # about 14.6 - a strong test when it does fire


# ---------------------------------------------------------------------------
# 2.3  From pre-test to post-test probability
# ---------------------------------------------------------------------------
# Bayes' theorem in odds form is a single multiplication:
#
#   post-test odds = pre-test odds * LR+
#
# Read it as: start with what you believed before the test, multiply by how much
# this result should shift that belief, and convert back to a probability.
#
# Step 1: pre-test odds * LR+ gives the post-test odds.
# Step 2: o / (1 + o) turns odds back into a probability.
#
# POST-TEST PROBABILITY is the answer to the patient's question: "given this
# result, what are the chances now?" It is what you would write in the notes
# after the test is back.

post_test_odds        <- pre_test_odds * lr_positive
post_test_probability <- post_test_odds / (1 + post_test_odds)

post_test_odds
post_test_probability

# The check: this should equal the PPV calculated directly from the 2 x 2 table.
# It does. The two routes are the same calculation wearing different clothes,
# which is a useful thing to know because exam questions sometimes ask you to
# show they agree.

positive_predictive_value

# Why bother with the odds version at all if the table gives the same answer? Two
# reasons. A 2 x 2 table needs a whole study population to build, whereas the
# Bayes route lets you start from any pre-test probability you like, including
# one for a patient who would never have been in that study. And the likelihood
# ratio is portable, so you can reuse a published LR+ with your own estimate of
# how likely the disease is.


# ---------------------------------------------------------------------------
# EXERCISE 3 - Change the pre-test probability
# ---------------------------------------------------------------------------
# Keep the same sensitivity and specificity. Now pretend the patient in front of
# you has a pre-test probability of 0.05 instead of 0.25. What is the post-test
# probability after a positive result? Then try 0.95.
#
# Only lr_positive is carried over. It never changes, because it is built from
# sensitivity and specificity.

# A low starting point: disease is unlikely before the test is done.
low_pre_test_probability  <- 0.05
low_pre_test_odds         <- low_pre_test_probability / (1 - low_pre_test_probability)
low_post_test_odds        <- low_pre_test_odds * lr_positive
low_post_test_probability <- low_post_test_odds / (1 + low_post_test_odds)

# A high starting point: disease is already strongly suspected.
high_pre_test_probability  <- 0.95
high_pre_test_odds         <- high_pre_test_probability / (1 - high_pre_test_probability)
high_post_test_odds        <- high_pre_test_odds * lr_positive
high_post_test_probability <- high_post_test_odds / (1 + high_post_test_odds)

round(low_post_test_probability, 3)    # about 0.434
round(high_post_test_probability, 3)   # about 0.996

# Read those two answers carefully, because this is the point of the exercise.
#
# From 0.05, a positive result lifts the probability to about 0.43. That is a
# big jump in relative terms - more than eight times the starting odds - but it
# still leaves the patient more likely NOT to have the disease than to have it. A
# positive result on a strong test is not the same thing as a diagnosis.
#
# From 0.95, a positive result pushes the probability to about 0.996. Once you
# already believe the disease is likely, the test mostly confirms what you
# thought.
#
# Same test, same LR+, wildly different meanings. The pre-test probability is
# doing most of the work, and this is precisely why screening whole populations
# with a test that is excellent in a clinic produces so many false alarms.


# ---------------------------------------------------------------------------
# 2.4  The ROC curve: what it is
# ---------------------------------------------------------------------------
# A test that gives a number - a temperature, a blood marker, a score - has to be
# turned into a yes/no decision by choosing a cut-off. Above the cut-off you call
# it positive; below, negative. Move the cut-off and you get a different mix of
# sensitivity and specificity.
#
# An ROC curve shows every cut-off at once. Each point on the curve is one
# cut-off, plotted with:
#
#   horizontal axis = false positive rate = 1 - specificity  (the alarms)
#   vertical axis   = sensitivity                            (the catches)
#
# Both axes run from 0 to 1. At the bottom left you are strict: almost nothing is
# called positive, so you catch few cases and raise few false alarms. At the top
# right you are lax: almost everything is called positive, so you catch every
# case and alarm everyone. The curve is the trail of compromises between them.
#
# Two landmarks anchor the plot:
#   - the top left corner (0, 1) is a perfect test: every case caught, no false
#     alarms. Real curves bend towards it without reaching it.
#   - the diagonal line from (0, 0) to (1, 1) is a useless test. On that line the
#     false positive rate always equals the sensitivity, which is exactly what
#     you get by ignoring the test and tossing a coin.
#
# So the further the curve bows towards the top left, and the further it sits
# above the diagonal, the better the test.
#
# A full curve needs one row of data per patient - the test value and the true
# outcome. A 2 x 2 table cannot give you one, because it has already collapsed
# every patient into four boxes at a single cut-off. That is why the next two
# sections use a patient-level dataset.


# ---------------------------------------------------------------------------
# 2.5  One point on an ROC plot: APACHE-II
# ---------------------------------------------------------------------------
# At an APACHE-II cut-off of 8, the lecture gave this table. The thing being
# detected is a severe complication.
#
#                          Severe complications   Mild complications
# APACHE-II score >= 8              22                     5
# APACHE-II score < 8                5                     8
#
# The code below draws the axes, the diagonal reference line, and then adds the
# single point that this one cut-off produces.

plot(
  c(0, 1),                                    # x coordinates of the line ends
  c(0, 1),                                    # y coordinates of the line ends
  type = "l",                                 # "l" joins the points with a line
  lty  = 20,                                  # line type, dashed
  col  = "grey50",                            # line colour
  xlab = "False positive rate (1 - specificity)",
  ylab = "Sensitivity",
  main = "One point on an ROC plot",
  xlim = c(0, 1),                             # x-axis limits
  ylim = c(0, 1)                              # y-axis limits
)

# WHAT THIS PLOT TELLS US: the dashed diagonal is the "no better than guessing"
# line. Everything that matters will be judged against it. The axes are fixed at
# 0 to 1 so that the whole possible range of a test is visible before any data
# point is added - a plot that rescaled itself around one point would make that
# point look more impressive than it is.
#
# Note the two plot() calls used in this script. This first one draws from raw
# coordinates, which is what you need when there is no object to plot yet. From
# 2.6 onwards, plot() is handed an ROC object and R draws the curve itself. Both
# produce an ROC plot; the difference is whether you supply coordinates or a
# fitted object.


# ---------------------------------------------------------------------------
# EXERCISE 4 - Place the APACHE-II point on the plot
# ---------------------------------------------------------------------------
# Calculate sensitivity, specificity and the false positive rate at a cut-off
# of 8, then add the point to the plot.
#
#   sensitivity = 22 / (22 + 5)   severe cases the cut-off catches
#   specificity =  8 / (8  + 5)   mild cases the cut-off correctly clears
#   false positive rate = 1 - specificity

apache_sensitivity         <- 22 / (22 + 5)
apache_specificity         <- 8 / (8 + 5)
apache_false_positive_rate <- 1 - apache_specificity

apache_sensitivity          # about 0.815
apache_specificity          # about 0.615
apache_false_positive_rate  # about 0.385

# points() adds to the plot already on screen, so run it while the plot from 2.5
# is still there. If the plot has been closed or overwritten, re-run section 2.5
# first.
#   pch = 19   a solid circle
#   cex = 1.5  make it 1.5 times the usual size

points(
  apache_false_positive_rate,
  apache_sensitivity,
  pch = 19,
  col = "steelblue",
  cex = 1.5
)

# WHAT THIS PLOT TELLS US: one point sits above the diagonal, so this cut-off
# does better than chance - at 8, APACHE-II catches about 82% of severe
# complications while raising an alarm in about 39% of the mild ones. It is a
# reasonable but not a decisive test.
#
# What it does NOT tell us is whether 8 is the best cut-off. There is nothing to
# compare it with, because a single threshold gives a single point. The curve
# that would answer that question is the next section.

# DISCUSSION: what does this single point represent, and why is it not a whole
# ROC curve?
#
# The point is one sensitivity/specificity pair, produced by one cut-off. Choose
# a different cut-off and you get a different pair, sitting somewhere else on the
# plot. A complete ROC curve is the trail left behind as the cut-off sweeps from
# the lowest to the highest value.
#
# To draw that trail you need the individual test value and the true outcome for
# every patient. The 2 x 2 table has already thrown that away.


# ---------------------------------------------------------------------------
# 2.6  A complete ROC curve: S100B in the aSAH data
# ---------------------------------------------------------------------------
# A package is an add-on that gives R new functions or data. A package is
# installed once, but it must be loaded again at the start of every new R
# session.
#
# Install pROC only if it is not already on your machine. This needs an internet
# connection, so run it once by hand and then leave it commented out.

# install.packages("pROC")

# library() loads an installed package into the current session.

library(pROC)

# data() loads a dataset that ships with a package. aSAH covers patients with
# aneurysmal subarachnoid haemorrhage. Each row is one patient.
#   outcome  the result, either "Good" or "Poor"
#   s100b    a blood marker, measured on a continuous scale
#
# S100B is continuous, so there are many possible cut-offs and a full ROC curve
# is worth drawing. Nothing here is a yes/no count - this is the situation ROC
# curves were invented for.

data(aSAH)
head(aSAH)              # the first six rows, to see the layout
table(aSAH$outcome)     # how many patients in each outcome group
summary(aSAH$s100b)     # smallest, quartiles, median, largest

# Glance at table() and summary() before moving on. table() tells you whether the
# two outcome groups are balanced, and summary() shows the range of the marker.
# If one group had only a handful of patients, the curve would be based on very
# little information and we would treat the AUC with caution.


# ---------------------------------------------------------------------------
# EXERCISE 5 - The ROC curve for S100B
# ---------------------------------------------------------------------------
# roc() builds the whole curve.
#   response  the true outcome, one entry per patient
#   predictor the measured test value
#   levels    which group is the reference and which is the one being detected;
#             here "Good" is the reference and "Poor" is what we want to find
#   direction "<" means HIGHER S100B values point towards a Poor outcome

s100b_roc <- roc(
  response  = aSAH$outcome,
  predictor = aSAH$s100b,
  levels    = c("Good", "Poor"),
  direction = "<"
)

# plot() knows what an ROC object is and draws the curve.
#   legacy.axes = TRUE  put the false positive rate on the horizontal axis,
#                       rather than the specificity R would use by default
#   identity    = TRUE  add the diagonal reference line
#   lwd         = 2     line width

plot(
  s100b_roc,
  legacy.axes = TRUE,
  identity    = TRUE,
  col         = "steelblue",
  lwd         = 2,
  xlab        = "False positive rate (1 - specificity)",
  ylab        = "Sensitivity",
  main        = "ROC curve for S100B"
)

# WHAT THIS PLOT TELLS US: the curve bows well above the diagonal, so S100B
# separates Poor from Good outcomes better than chance. It rises steeply at the
# left, which means a low cut-off buys a lot of sensitivity for very few false
# alarms - the marker is at its most useful in that region. The whole curve sits
# below the top left corner, so no cut-off gives a perfect result; every point
# trades some alarms for some catches.
#
# legacy.axes = TRUE is worth understanding rather than copying. By default R
# labels the horizontal axis with specificity running from 1 down to 0, which
# reads right to left. Cancer Research UK and most clinical texts, including
# this course, plot the false positive rate increasing left to right instead.
# The curve is identical either way - only the label on the axis changes.

# auc() gives the area under the curve. It is a single number summarising the
# whole curve.
#
#   AUC = 0.5   the test is no better than guessing
#   AUC = 0.7   the usual rough description is "poor to fair"
#   AUC = 0.8   "good discrimination"
#   AUC = 0.9   "excellent"
#   AUC = 1.0   the test separates the two groups perfectly
#
# A useful way to read AUC that does not involve areas at all: pick one patient
# with a Poor outcome and one with a Good outcome at random. The AUC is the
# chance that the Poor patient has the higher S100B value. An AUC of 0.8 means
# that happens 80% of the time.

s100b_auc <- auc(s100b_roc)
s100b_auc

# WHAT THIS NUMBER TELLS US: it condenses the whole curve into one figure you can
# compare across tests and quote in a report. Its weakness is that it averages
# over every cut-off, including ones nobody would ever use. Two tests can share
# an AUC while being useful in quite different regions of the curve, so an AUC is
# a summary, not the whole story - which is why you also look at the curve.

# coords() pulls numbers out of the curve. Setting x = "best" asks for the
# cut-off that best balances sensitivity and specificity. R finds it by
# maximising Youden's index, which is sensitivity + specificity - 1. Geometrically
# that is the point on the curve furthest above the diagonal.

s100b_best_cutoff <- coords(
  s100b_roc,
  x   = "best",
  ret = c("threshold", "sensitivity", "specificity")
)

s100b_best_cutoff

# WHAT THIS OUTPUT TELLS US: it turns the abstract curve back into something you
# could act on. The threshold is a real S100B value, and the two proportions
# beside it are what you would get if you adopted that number as your cut-off.
# Everything in the object above could go into a clinical protocol.
#
# A caution worth writing down: "best" here means best by one particular rule.
# In practice the right cut-off depends on what a miss costs compared with an
# alarm. If missing a Poor outcome is far worse than a false alarm, you would
# deliberately move to a lower threshold and accept more alarms - a different
# point on the same curve.

# DISCUSSION: is the AUC closer to 0.5 or to 1, and what do the two numbers at
# the best cut-off mean?
#
# The AUC is well above 0.5, so S100B separates the two groups far better than
# chance. At the best cut-off, the sensitivity is the proportion of Poor outcomes
# the marker catches correctly, and the specificity is the proportion of Good
# outcomes it correctly clears. Read both straight off the output above. Together
# they tell you the price of that cut-off: every case you catch is bought with
# some number of false alarms.


################################################################################
# PART 3. THE BINOMIAL DISTRIBUTION
################################################################################

# ---------------------------------------------------------------------------
# 3.1  What the binomial distribution is for
# ---------------------------------------------------------------------------
# Part 2 was about patients one at a time. From here on the question changes.
# Instead of "what does this result mean for this patient?", we ask "if I repeat
# this situation many times, how many successes will I get?" That is what a
# probability distribution answers.
#
# The binomial distribution answers questions of this shape:
#
#   "I repeat the same yes/no trial a fixed number of times. What is the chance
#    of getting exactly this many yeses?"
#
# Four conditions have to hold:
#   1. The number of trials is fixed in advance.
#   2. Each trial has only two outcomes, which we call success and failure.
#   3. The trials are independent - one result does not change the next.
#   4. The probability of success is the same on every trial.
#
# When people say "success" here they do not mean something good. It is just the
# label for whichever outcome you are counting. Counting deaths in a trial would
# mean "success" = death, which sounds odd but is perfectly standard.
#
# A quick test of condition 4: if your patients are not exchangeable - if some
# are older, sicker or on a different treatment - then a single probability does
# not apply to all of them and the binomial is the wrong model.
#
# R has four functions for this family, and they share a pattern. The first
# letter tells you what you get back:
#
#   dbinom(x, size, prob)   d for density    -> probability of EXACTLY x
#   pbinom(q, size, prob)   p for cumulative -> probability of AT MOST q
#   qbinom(p, size, prob)   q for quantile   -> the inverse of pbinom
#   rbinom(n, size, prob)   r for random     -> simulate n random results
#
# The arguments mean the same thing in all of them:
#   x or q  how many successes we are asking about
#   size    how many trials in total
#   prob    the probability of success on each single trial
#
# You only need dbinom() and pbinom() for this course. The other two are worth
# knowing by name, because once the pattern clicks you can guess what an
# unfamiliar function does from its first letter.


# ---------------------------------------------------------------------------
# 3.2  The survey example
# ---------------------------------------------------------------------------
# We contact 4 people. Each has a 46% chance of responding.
#
#   size = 4      four trials
#   prob = 0.46   chance of a response from each person
#
# The four people must be independent: one person replying does not make the next
# person more or less likely to reply.

# Probability of ZERO responses. x = 0 means nobody replies.
# This is all four failing in a row: 0.54 * 0.54 * 0.54 * 0.54.

probability_zero_responses <- dbinom(x = 0, size = 4, prob = 0.46)

# Probability of EXACTLY ONE response. x = 1 means one person replies.
# There are four ways this can happen - it could be any one of the four people -
# so this probability is four times the chance of one specific person replying
# while the other three do not. R does not need to be told that; the formula
# handles it. That "four ways" is the part of the binomial formula that people
# most often forget when doing it by hand.

probability_one_response <- dbinom(x = 1, size = 4, prob = 0.46)

probability_zero_responses   # about 0.0850, or 8.5%
probability_one_response     # about 0.2897, or 29.0%

# Naming the arguments every time (x =, size =, prob =) is a habit worth keeping.
# R will happily accept them in the wrong order and give you a plausible wrong
# answer without any warning.


# ---------------------------------------------------------------------------
# EXERCISE 6 - At most one response
# ---------------------------------------------------------------------------
# "At most one" means zero or one. Those two events cannot both happen, so their
# probabilities simply add. This is the addition rule for mutually exclusive
# events.
#
# Adding the two numbers from 3.2 gives the answer. pbinom() should give the same
# thing directly, and that agreement is the check.

probability_at_most_one_sum <- probability_zero_responses + probability_one_response

probability_at_most_one <- pbinom(q = 1, size = 4, prob = 0.46)

probability_at_most_one_sum
probability_at_most_one   # identical, so the calculation checks out


# ---------------------------------------------------------------------------
# 3.3  The whole distribution
# ---------------------------------------------------------------------------
# The possible numbers of responses are 0, 1, 2, 3 and 4. Nothing else can
# happen, since only four people were contacted.
#
# The colon operator builds the sequence of whole numbers from 0 to 4. dbinom()
# accepts a list of values in one go, so a single command covers every possible
# outcome.

responses              <- 0:4
response_probabilities <- dbinom(x = responses, size = 4, prob = 0.46)

responses
response_probabilities

# The probabilities must add to 1, because every possible outcome is in the list.
# It is always worth checking - it is a free way to catch a mistake.

sum(response_probabilities)


# ---------------------------------------------------------------------------
# 3.4  Plotting the binomial distribution
# ---------------------------------------------------------------------------
# barplot() draws one bar per value. It was introduced in Practical 1.
# names.arg supplies the label printed under each bar.

barplot(
  response_probabilities,
  names.arg = responses,
  xlab = "Number responding",
  ylab = "Probability",
  main = "Binomial distribution: n = 4, probability = 0.46",
  col  = "lightblue"
)

# WHAT THIS PLOT TELLS US: the four bars are the whole distribution, and together
# they are every outcome that can happen.
#
# The tall bar at 2 is the most likely outcome, which is not a coincidence - with
# 4 trials and a 0.46 chance, the expected number is 1.84, and 2 is the nearest
# whole number. The bar at 5 is missing because it is impossible: you cannot get
# five responses from four people. The distribution stops dead there.
#
# The shape is slightly lopsided, leaning left, because the success probability
# is just under half. It would be symmetric at 0.5 and would pile up at the left
# or right end as the probability moved towards 0 or 1.
#
# Read the heights as probabilities of a single outcome, and remember they add to
# 1: about 8.5% of the time nobody responds, 29% exactly one, and so on. If you
# repeated this survey with 4 new people many times over, the number responding
# would follow these proportions. A barplot of a discrete distribution is always
# the right picture, because the counts 0, 1, 2, 3, 4 are separate values with
# nothing in between - there is no such thing as 2.5 responses.


# ---------------------------------------------------------------------------
# 3.5  Mean and variance
# ---------------------------------------------------------------------------
# For a binomial distribution there are two standard formulas.
#
#   mean     = n * pi          the expected number of successes
#   variance = n * pi * (1 - pi)
#
# The mean is what you would get if you averaged the number of successes over
# countless repetitions of the whole experiment. It is the balance point of the
# barplot.
#
# The variance measures how spread out the possible counts are. Notice that it is
# largest when pi is 0.5 and shrinks towards zero as pi approaches 0 or 1. That
# makes sense: if success is either almost certain or almost impossible, the
# number of successes is easy to predict, so there is little spread.
#
# sqrt() takes a square root, which turns the variance into the standard
# deviation, measured in the same units as the mean.

binomial_mean     <- 4 * 0.46
binomial_variance <- 4 * 0.46 * (1 - 0.46)
binomial_sd       <- sqrt(binomial_variance)

binomial_mean       # 1.84 responses expected, on average
binomial_variance   # about 0.9936
binomial_sd         # about 0.997 - roughly one response either side of 1.84

# Tie this back to the plot in 3.4. The mean of 1.84 is the balance point of
# those four bars, sitting between the tall bar at 2 and its neighbour at 1. The
# standard deviation of about 1 says that a count a fair distance from 1.84 is
# entirely unremarkable - 0 responses or 3 responses are neither rare nor
# surprising, which is exactly what the barplot shows.


# ---------------------------------------------------------------------------
# EXERCISE 7 - Ten patients, probability 0.25
# ---------------------------------------------------------------------------
# Ten patients are treated. Each has a 0.25 chance of responding.

# (a) Exactly 3 respond  -> dbinom(), because "exactly" is a single outcome.
probability_exactly_three <- dbinom(x = 3, size = 10, prob = 0.25)

# (b) At most 3 respond  -> pbinom(), because "at most" adds up 0, 1, 2 and 3.
probability_at_most_three <- pbinom(q = 3, size = 10, prob = 0.25)

# (c) Expected number who respond -> the mean formula, n * pi.
expected_responses <- 10 * 0.25

probability_exactly_three   # about 0.2503
probability_at_most_three   # about 0.7759
expected_responses          # 2.5

# A detail worth noticing: "at most 3" means 3 is included. "Fewer than 3" would
# have been pbinom(q = 2, ...). Getting this wrong shifts the answer by one whole
# outcome, and it is the most common slip with pbinom().
#
# A second check worth doing: "exactly 3" is one of the four outcomes counted in
# "at most 3". So (a) can never be larger than (b). Here 0.25 is comfortably
# inside 0.78, which is what you would expect - 3 responses is a fairly typical
# result when the average is 2.5, so the cut-off at 3 sits near the middle of the
# distribution and captures most of it.


################################################################################
# PART 4. THE POISSON DISTRIBUTION
################################################################################

# ---------------------------------------------------------------------------
# 4.1  What the Poisson distribution is for
# ---------------------------------------------------------------------------
# The Poisson distribution answers a different kind of question:
#
#   "Events happen at some average rate. What is the chance of getting exactly
#    this many of them in a given stretch of time?"
#
# The binomial counts successes out of a fixed number of trials. The Poisson
# counts events in a fixed interval, and there is no upper limit on how many
# could occur. That is the central difference between the two parts of this
# practical, and Part 5 comes back to it.
#
# Three conditions have to hold:
#   1. Events happen independently of one another.
#   2. Events happen at a constant average rate across the interval.
#   3. Two events cannot occur at exactly the same instant.
#
# Condition 2 is the one to interrogate in practice. Admissions do not arrive at
# a constant rate around the clock - there are quiet nights and busy afternoons -
# so a Poisson model over a whole day may hide the structure. Choosing the
# interval carefully, such as one hour during the day shift, is often what makes
# the assumption reasonable.


# ---------------------------------------------------------------------------
# 4.2  Lambda - the one number that controls everything
# ---------------------------------------------------------------------------
# A Poisson distribution has a single parameter, lambda. Everything about the
# distribution is decided by it.
#
# WHAT LAMBDA MEANS. Lambda is the AVERAGE number of events expected in the
# interval you are looking at. Not the most likely number - the average. If a
# hospital sees a long-run average of 4 admissions per hour, then lambda = 4 for
# a one-hour interval.
#
# You do not choose lambda; you estimate it from data. The usual estimate is
# simply the observed mean: count the events over many intervals and average
# them. A year of monthly clinic attendance with an average of 1.1 suitable
# donors per month gives lambda = 1.1.
#
# THE MOST IMPORTANT FACT IN THIS SECTION. For a Poisson distribution the mean
# and the variance are BOTH equal to lambda.
#
#   mean     = lambda
#   variance = lambda
#   standard deviation = sqrt(lambda)
#
# Say it again in words. If the average is 4 events per hour, the variance is
# also 4, and the standard deviation is 2. This is unusual - for most
# distributions the mean and the variance are unrelated - and it has three
# consequences worth remembering:
#
#   - Everything is driven by one number. Know lambda and you know the whole
#     distribution.
#   - The spread grows with the rate. Raise lambda and the distribution moves
#     right AND becomes wider.
#   - The standard deviation grows only as the square root of lambda. Going from
#     lambda = 1 to lambda = 4 quadruples the rate but only doubles the spread.
#     Busier intervals are proportionally more predictable than quiet ones.
#
# THE INTERVAL MUST MATCH. Lambda always belongs to a stated interval, and it has
# to match the interval you are asking about. If the rate is 4 admissions per
# hour:
#
#   lambda = 4    for a one-hour interval
#   lambda = 8    for a two-hour interval (twice as long, twice the average)
#   lambda = 0.5  for a 7.5-minute interval (an eighth as long)
#
# Getting this wrong is the most common error with this distribution, and it is
# worth a habit: before calling dpois() or ppois(), say the interval to yourself
# and check that lambda is expressed over that same stretch.
#
# THE R FUNCTIONS. The same four-function family as the binomial:
#
#   dpois(x, lambda)   the probability of EXACTLY x events
#   ppois(q, lambda)   the CUMULATIVE probability of AT MOST q events
#   qpois(p, lambda)   the quantile, the inverse of ppois
#   rpois(n, lambda)   simulate n random counts
#
# Note what has gone: size and prob are replaced by this single lambda. That is
# the whole difference in the syntax between the binomial and the Poisson. It is
# also a clue to the difference in meaning - there is no "number of trials" in a
# Poisson problem, because the events are not being counted out of a fixed set of
# opportunities.


# ---------------------------------------------------------------------------
# 4.3  The blood-donor example
# ---------------------------------------------------------------------------
# A clinic gets an average of 1.1 suitable donors per year. Over one year,
# lambda = 1.1.
#
# Probability of no donors at all in a year, x = 0.

probability_no_donors <- dpois(x = 0, lambda = 1.1)
probability_no_donors

# This reproduces the lecture result: about 0.333, so roughly a one in three
# chance of a year with no donors.

round(probability_no_donors, 3)

# Probability of at most one donor, which means zero or one.

probability_at_most_one_donor <- ppois(q = 1, lambda = 1.1)
probability_at_most_one_donor

# WHY A DONORLESS YEAR IS NOT ALARMING. The mean and the variance both equal
# lambda, so here both are 1.1, and the standard deviation is sqrt(1.1), about
# 1.05 - very nearly as large as the mean itself. When the spread is as big as
# the average, counts of zero are entirely ordinary. With a mean of 1.1 donors,
# the most likely single outcome is actually zero, not one.
#
# This is the practical value of the model: it stops a quiet year being read as a
# sign that something has gone wrong, and it gives you a basis for deciding when
# a count really is unusual.

poisson_donor_mean <- 1.1
poisson_donor_var  <- 1.1
poisson_donor_sd   <- sqrt(1.1)

poisson_donor_mean
poisson_donor_var
poisson_donor_sd


# ---------------------------------------------------------------------------
# 4.4  Plotting the blood-donor distribution
# ---------------------------------------------------------------------------
# Seeing the shape makes lambda far easier to interpret than reading probabilities
# one at a time. A small lambda first, so that there is something to compare
# against the hospital example later.

donors             <- 0:8
donor_probabilities <- dpois(x = donors, lambda = 1.1)

barplot(
  donor_probabilities,
  names.arg = donors,
  xlab = "Number of donors in a year",
  ylab = "Probability",
  main = "Poisson distribution: lambda = 1.1",
  col  = "palegreen"
)

# WHAT THIS PLOT TELLS US: the tallest bar is at 0, not at 1. That is the visual
# version of everything in 4.3 - when lambda is small, zero events is the single
# most likely outcome. The bars fall away steeply: 0 and 1 together cover the
# great majority of the probability, and anything beyond 3 is barely visible.
#
# The distribution is strongly right-skewed, with a long thin tail. The reason is
# built into the situation: counts cannot go below zero, so the distribution is
# walled in on the left, but there is no ceiling on the right - a year with 7
# donors is possible, just unlikely. Comparisons with lambda = 4 in the next
# section show both of these features changing at once.


# ---------------------------------------------------------------------------
# EXERCISE 8 - Emergency admissions
# ---------------------------------------------------------------------------
# A hospital receives an average of 4 emergency admissions per hour. For a
# one-hour interval, lambda = 4.

# (a) Exactly 3 admissions, in one hour.
probability_exactly_three_admissions <- dpois(x = 3, lambda = 4)

# (b) At most 3 admissions, in one hour. This adds up 0, 1, 2 and 3.
probability_at_most_three_admissions <- ppois(q = 3, lambda = 4)

# (c) More than 3 admissions, in one hour.
# "More than 3" and "at most 3" are the only two possibilities, and between them
# they cover every case, so their probabilities add to 1. Subtracting from 1
# gives the answer without adding up the single values 4, 5, 6 and onwards,
# which would never finish anyway.
probability_more_than_three_admissions <- 1 - ppois(q = 3, lambda = 4)

probability_exactly_three_admissions       # about 0.1954
probability_at_most_three_admissions       # about 0.4335
probability_more_than_three_admissions     # about 0.5665

# Spot-check the last two: 0.4335 + 0.5665 = 1. A complementary pair must always
# sum to 1, which makes this a quick way to confirm you subtracted the right
# thing.
#
# Part (c) is also a small lesson in why cumulative functions exist. "More than 3"
# means 4, 5, 6, 7, and onwards with no end. Adding those one by one is
# impossible, but the complement of "at most 3" reaches the same answer in a
# single step. Whenever a question says "more than", "at least" or "greater
# than", look for the complement first.

# (d) The mean and the variance here are both 4, and the standard deviation is
# the square root of 4, which is exactly 2.

poisson_mean     <- 4
poisson_variance <- 4
poisson_sd       <- sqrt(4)

poisson_mean
poisson_variance
poisson_sd

# COMPARE THE TWO EXAMPLES. With lambda = 1.1 the distribution was crowded
# against zero, and about a third of all intervals had no events. With lambda = 4
# the centre has moved out to 4, and zero events are rare. The mean moved from
# 1.1 to 4 - a factor of about 3.6 - while the standard deviation moved only from
# 1.05 to 2. That is the square-root relationship from 4.2 in action, and it is
# the reason busier services are relatively easier to plan for: their volume is
# larger but their proportional variability is smaller.


# ---------------------------------------------------------------------------
# 4.5  Plotting the hospital distribution
# ---------------------------------------------------------------------------
# The same picture for lambda = 4, so the two can be compared side by side.

admissions              <- 0:12
admission_probabilities <- dpois(x = admissions, lambda = 4)

barplot(
  admission_probabilities,
  names.arg = admissions,
  xlab = "Number of admissions in an hour",
  ylab = "Probability",
  main = "Poisson distribution: lambda = 4",
  col  = "wheat"
)

# WHAT THIS PLOT TELLS US: compare it with the lambda = 1.1 plot above and three
# things have changed.
#
# The peak has moved right, from 0 to about 3 or 4. That is the mean following
# lambda.
#
# The distribution is wider. The bars around the peak are still substantial
# several counts away from it, whereas at lambda = 1.1 the probability collapsed
# almost immediately. That is the variance following lambda.
#
# The skew is milder. At lambda = 1.1 the distribution was pressed hard against
# zero with a long tail; here the left tail has more room and the shape is closer
# to symmetric. As lambda grows further it becomes more symmetric still.
#
# A useful habit is to read a barplot like this as a prediction about the quiet
# periods as well as the busy ones. Zero admissions in an hour is still possible
# at lambda = 4 - the bar at 0 has visible height - but it is now a quiet hour
# rather than a normal one. That is the difference between a system that can be
# staffed for the average and one that needs slack for the tail.

# The probabilities for every possible count must add to 1. We only plotted 0 to
# 12, so the values we plotted add to slightly less than 1. The missing sliver is
# the probability of 13 or more admissions.

sum(admission_probabilities)   # just under 1, and the gap is the far tail

# That gap is worth understanding rather than ignoring. It is the reason we plot
# a generous range: with lambda = 4 the tail beyond 12 is tiny, so cutting it off
# costs almost nothing. With a large lambda, the same range would hide a
# substantial tail, and the barplot would be quietly misleading.


################################################################################
# PART 5. BINOMIAL OR POISSON?
################################################################################

# ---------------------------------------------------------------------------
# 5.1  The Poisson as an approximation to the binomial
# ---------------------------------------------------------------------------
# There is a link between the two distributions. When the number of trials is
# large and the probability of success is small, a binomial distribution can be
# approximated by a Poisson distribution with lambda = n * pi.
#
# The intuition is that many opportunities, each almost certainly a failure, look
# the same as a rare event arriving at a steady rate. Counting how many of 1000
# people develop a rare condition is, for practical purposes, the same problem as
# counting how many cases arrive in a year.
#
# Here n = 1000 and pi = 0.001, so lambda = 1.

binomial_probability_zero <- dbinom(x = 0, size = 1000, prob = 0.001)
poisson_probability_zero  <- dpois(x = 0, lambda = 1)

binomial_probability_zero
poisson_probability_zero

# c() combines the two numbers into one list so a single round() call formats
# both at once.

round(c(binomial_probability_zero, poisson_probability_zero), 4)

# The two values agree to several decimal places. Why does this matter? Because
# the Poisson is much easier to work with - one parameter instead of two, and a
# cumulative function that is simple to use - so being able to swap one for the
# other is a genuine practical saving. The "large n, small pi" rule of thumb is
# the condition under which the swap is safe.


# ---------------------------------------------------------------------------
# 5.2  Choosing the right model
# ---------------------------------------------------------------------------
# The question to ask is whether there is a fixed number of trials.
#
# 1. The number of patients responding among 20 given a treatment.
#    -> Binomial. Twenty fixed trials, each patient responds or does not, and a
#       common probability of response.
#
# 2. The number of emergency calls during one hour.
#    -> Poisson. No fixed number of trials. Calls arrive independently at a
#       roughly constant rate inside a time interval, and there is no ceiling on
#       how many might come.
#
# 3. The number of positive tests among 50 people each with the same probability
#    of testing positive.
#    -> Binomial. Fifty fixed trials with a common probability.
#
# 4. The number of cases of a rare disease in a town during one year.
#    -> Poisson. Events counted over a fixed time interval, with no fixed number
#       of opportunities and a low rate.
#
# In one line: a FIXED NUMBER OF TRIALS with a yes/no answer is binomial. A COUNT
# OF EVENTS over an interval of time, space or volume, with no fixed number of
# opportunities, is Poisson.
#
# Two tie-breakers for the awkward cases:
#
#   - If you can write down the maximum possible count, it is probably binomial.
#     The maximum is the number of trials. If there is no natural maximum, it is
#     probably Poisson.
#   - If the answer is a proportion out of a known total ("7 of 20 responded"),
#     binomial. If the answer is a count with no total attached ("7 admissions
#     arrived"), Poisson.

# FINAL CHECKLIST. If you can do these from memory, this practical is covered:
#   1. Build a 2 x 2 table and label all four cells.
#   2. Calculate sensitivity, specificity, PPV and NPV from it, and say which
#      denominator belongs to which.
#   3. Explain why PPV changes with case mix but sensitivity does not.
#   4. Convert a probability to odds and back.
#   5. Use LR+ to move from a pre-test to a post-test probability.
#   6. Say what a point on an ROC curve represents and what the diagonal is.
#   7. Read an AUC as the chance that a case scores higher than a control.
#   8. Use dbinom() and pbinom(), and say what size and prob mean.
#   9. Use dpois() and ppois(), and say what lambda means and which interval it
#      belongs to.
#  10. State the mean and variance of both distributions and say why the binomial
#      has two parameters and the Poisson only one.

###############################################################################
# END OF SCRIPT
###############################################################################
