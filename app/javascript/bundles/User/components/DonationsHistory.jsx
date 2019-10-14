import React from 'react'
import PropTypes from 'prop-types'
import numeral from 'numeral'
import moment from 'moment'
import { makeStyles } from '@material-ui/core/styles'
import Table from '@material-ui/core/Table'
import TableBody from '@material-ui/core/TableBody'
import TableCell from '@material-ui/core/TableCell'
import TableHead from '@material-ui/core/TableHead'
import TableRow from '@material-ui/core/TableRow'
import Paper from '@material-ui/core/Paper'

const useStyles = makeStyles(theme => ({
  root: {
    width: '100%',
    marginTop: theme.spacing(3),
    padding: theme.spacing(4),
    overflowX: 'auto'
  },
  table: {
    minWidth: 650
  }
}))

const DONATION_TYPES = {
  ONE_OFF: 'One time Donation',
  SUBSCRIPTION: 'Monthly Subscription'
}

const calcDonationTotal = donations => {
  return donations.reduce((acc, donation) => (acc += donation), 0)
}

function DonationsView ({ activePlan, donations }) {
  const classes = useStyles()
  const donatedAmount = calcDonationTotal(
    donations.map(donation => Number(donation.amount))
  )

  return (
    <Paper className={classes.root}>
      <h3>Your Donations History</h3>
      {activePlan && (
        <p>
          You're <strong>currently subscribed to {activePlan.name}</strong>.
        </p>
      )}
      <p>
        You have donated:{' '}
        <strong>{numeral(donatedAmount).format('$0,0.00')}</strong>
      </p>
      <Table className={classes.table}>
        <TableHead>
          <TableRow>
            <TableCell>Status</TableCell>
            <TableCell>Customer Stripe ID</TableCell>
            <TableCell>Type</TableCell>
            <TableCell>Donated at</TableCell>
            <TableCell>Amount</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {donations.map(donation => (
            <TableRow key={donation.id} id={`donation-${donation.id}`}>
              <TableCell scope='donation' className='capitalized'>
                {donation.status}
              </TableCell>
              <TableCell>{donation.customer_stripe_id}</TableCell>
              <TableCell>
                {DONATION_TYPES[donation.donation_type] || 'Other'}
              </TableCell>
              <TableCell>
                {moment(donation.created_at).format('MMMM Do YYYY, h:mm:ss a')}
              </TableCell>
              <TableCell>
                {numeral(donation.amount).format('$0,0.00')}
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
      <br />
      <small>
        <b>Important information:</b> Your Customer Stripe ID can be used to do
        any claims on the charges made. Please provide this ID for further help
        on any inquiry.
      </small>
    </Paper>
  )
}

DonationsView.propTypes = {
  activePlan: PropTypes.object,
  donations: PropTypes.array
}

export const DonationsHistory = props => <DonationsView {...props} />
