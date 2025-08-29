"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { MapPin, Video, CheckCircle } from "lucide-react"
import { cn } from "@/lib/utils"

const timeSlots = [
  "9:00 AM",
  "9:30 AM",
  "10:00 AM",
  "10:30 AM",
  "11:00 AM",
  "11:30 AM",
  "2:00 PM",
  "2:30 PM",
  "3:00 PM",
  "3:30 PM",
  "4:00 PM",
  "4:30 PM",
]

const availableDates = [
  { date: "2024-01-15", day: "Mon", available: true },
  { date: "2024-01-16", day: "Tue", available: true },
  { date: "2024-01-17", day: "Wed", available: false },
  { date: "2024-01-18", day: "Thu", available: true },
  { date: "2024-01-19", day: "Fri", available: true },
  { date: "2024-01-22", day: "Mon", available: true },
  { date: "2024-01-23", day: "Tue", available: true },
]

export function BookingModal({ doctor, isOpen, onClose }) {
  const [step, setStep] = useState(1)
  const [selectedDate, setSelectedDate] = useState("")
  const [selectedTime, setSelectedTime] = useState("")
  const [appointmentType, setAppointmentType] = useState("in-person")
  const [patientInfo, setPatientInfo] = useState({
    name: "",
    email: "",
    phone: "",
    reason: "",
  })
  const [isBooked, setIsBooked] = useState(false)

  const resetModal = () => {
    setStep(1)
    setSelectedDate("")
    setSelectedTime("")
    setAppointmentType("in-person")
    setPatientInfo({ name: "", email: "", phone: "", reason: "" })
    setIsBooked(false)
  }

  const handleClose = () => {
    resetModal()
    onClose()
  }

  const handleBooking = () => {
    setIsBooked(true)
    setTimeout(() => {
      handleClose()
    }, 2000)
  }

  const formatDate = (dateString) => {
    const date = new Date(dateString)
    return date.toLocaleDateString("en-US", {
      weekday: "short",
      month: "short",
      day: "numeric",
    })
  }

  if (!doctor) return null

  return (
    <Dialog open={isOpen} onOpenChange={handleClose}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center space-x-3">
            <img
              src={doctor.image || "/placeholder.svg"}
              alt={doctor.name}
              className="w-12 h-12 rounded-full object-cover"
            />
            <div>
              <div className="text-lg">Book Appointment</div>
              <div className="text-sm font-normal text-muted-foreground">
                {doctor.name} - {doctor.specialization}
              </div>
            </div>
          </DialogTitle>
        </DialogHeader>

        {isBooked ? (
          <div className="text-center py-8">
            <CheckCircle className="h-16 w-16 text-green-500 mx-auto mb-4" />
            <h3 className="text-xl font-semibold mb-2">Appointment Booked!</h3>
            <p className="text-muted-foreground">
              Your appointment with {doctor.name} has been confirmed for {formatDate(selectedDate)} at {selectedTime}.
            </p>
          </div>
        ) : (
          <div className="space-y-6">
            {/* Step Indicator */}
            <div className="flex items-center justify-center space-x-4">
              {[1, 2, 3].map((stepNumber) => (
                <div key={stepNumber} className="flex items-center">
                  <div
                    className={cn(
                      "w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium",
                      step >= stepNumber ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground",
                    )}
                  >
                    {stepNumber}
                  </div>
                  {stepNumber < 3 && (
                    <div className={cn("w-12 h-0.5 mx-2", step > stepNumber ? "bg-primary" : "bg-muted")} />
                  )}
                </div>
              ))}
            </div>

            {/* Step 1: Date & Time Selection */}
            {step === 1 && (
              <div className="space-y-6">
                <div>
                  <h3 className="text-lg font-semibold mb-4">Select Date & Time</h3>

                  {/* Date Selection */}
                  <div className="mb-6">
                    <Label className="text-sm font-medium mb-3 block">Available Dates</Label>
                    <div className="grid grid-cols-7 gap-2">
                      {availableDates.map((dateOption) => (
                        <Button
                          key={dateOption.date}
                          variant={selectedDate === dateOption.date ? "default" : "outline"}
                          size="sm"
                          disabled={!dateOption.available}
                          onClick={() => setSelectedDate(dateOption.date)}
                          className="flex flex-col h-auto py-3"
                        >
                          <span className="text-xs">{dateOption.day}</span>
                          <span className="text-sm">{new Date(dateOption.date).getDate()}</span>
                        </Button>
                      ))}
                    </div>
                  </div>

                  {/* Time Selection */}
                  {selectedDate && (
                    <div>
                      <Label className="text-sm font-medium mb-3 block">Available Times</Label>
                      <div className="grid grid-cols-3 sm:grid-cols-4 gap-2">
                        {timeSlots.map((time) => (
                          <Button
                            key={time}
                            variant={selectedTime === time ? "default" : "outline"}
                            size="sm"
                            onClick={() => setSelectedTime(time)}
                          >
                            {time}
                          </Button>
                        ))}
                      </div>
                    </div>
                  )}
                </div>

                <div className="flex justify-end">
                  <Button onClick={() => setStep(2)} disabled={!selectedDate || !selectedTime}>
                    Next
                  </Button>
                </div>
              </div>
            )}

            {/* Step 2: Appointment Type */}
            {step === 2 && (
              <div className="space-y-6">
                <div>
                  <h3 className="text-lg font-semibold mb-4">Choose Appointment Type</h3>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <Card
                      className={cn(
                        "cursor-pointer transition-all",
                        appointmentType === "in-person" ? "ring-2 ring-primary" : "",
                      )}
                      onClick={() => setAppointmentType("in-person")}
                    >
                      <CardContent className="p-6 text-center">
                        <MapPin className="h-8 w-8 mx-auto mb-3 text-primary" />
                        <h4 className="font-semibold mb-2">In-Person Visit</h4>
                        <p className="text-sm text-muted-foreground mb-3">Visit the doctor at their clinic</p>
                        <p className="text-sm font-medium">{doctor.location}</p>
                        <Badge variant="outline" className="mt-2">
                          ${doctor.consultationFee}
                        </Badge>
                      </CardContent>
                    </Card>

                    <Card
                      className={cn(
                        "cursor-pointer transition-all",
                        appointmentType === "video" ? "ring-2 ring-primary" : "",
                      )}
                      onClick={() => setAppointmentType("video")}
                    >
                      <CardContent className="p-6 text-center">
                        <Video className="h-8 w-8 mx-auto mb-3 text-primary" />
                        <h4 className="font-semibold mb-2">Video Consultation</h4>
                        <p className="text-sm text-muted-foreground mb-3">Meet with the doctor online</p>
                        <p className="text-sm font-medium">From your home</p>
                        <Badge variant="outline" className="mt-2">
                          ${doctor.consultationFee - 20}
                        </Badge>
                      </CardContent>
                    </Card>
                  </div>
                </div>

                <div className="flex justify-between">
                  <Button variant="outline" onClick={() => setStep(1)}>
                    Back
                  </Button>
                  <Button onClick={() => setStep(3)}>Next</Button>
                </div>
              </div>
            )}

            {/* Step 3: Patient Information */}
            {step === 3 && (
              <div className="space-y-6">
                <div>
                  <h3 className="text-lg font-semibold mb-4">Patient Information</h3>

                  <div className="space-y-4">
                    <div>
                      <Label htmlFor="name">Full Name</Label>
                      <Input
                        id="name"
                        value={patientInfo.name}
                        onChange={(e) => setPatientInfo({ ...patientInfo, name: e.target.value })}
                        placeholder="Enter your full name"
                      />
                    </div>

                    <div>
                      <Label htmlFor="email">Email Address</Label>
                      <Input
                        id="email"
                        type="email"
                        value={patientInfo.email}
                        onChange={(e) => setPatientInfo({ ...patientInfo, email: e.target.value })}
                        placeholder="Enter your email"
                      />
                    </div>

                    <div>
                      <Label htmlFor="phone">Phone Number</Label>
                      <Input
                        id="phone"
                        type="tel"
                        value={patientInfo.phone}
                        onChange={(e) => setPatientInfo({ ...patientInfo, phone: e.target.value })}
                        placeholder="Enter your phone number"
                      />
                    </div>

                    <div>
                      <Label htmlFor="reason">Reason for Visit</Label>
                      <Textarea
                        id="reason"
                        value={patientInfo.reason}
                        onChange={(e) => setPatientInfo({ ...patientInfo, reason: e.target.value })}
                        placeholder="Briefly describe your symptoms or reason for the appointment"
                        rows={3}
                      />
                    </div>
                  </div>

                  {/* Appointment Summary */}
                  <Card className="mt-6 bg-muted/50">
                    <CardHeader>
                      <CardTitle className="text-base">Appointment Summary</CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-2 text-sm">
                      <div className="flex justify-between">
                        <span>Doctor:</span>
                        <span className="font-medium">{doctor.name}</span>
                      </div>
                      <div className="flex justify-between">
                        <span>Date:</span>
                        <span className="font-medium">{formatDate(selectedDate)}</span>
                      </div>
                      <div className="flex justify-between">
                        <span>Time:</span>
                        <span className="font-medium">{selectedTime}</span>
                      </div>
                      <div className="flex justify-between">
                        <span>Type:</span>
                        <span className="font-medium capitalize">{appointmentType.replace("-", " ")}</span>
                      </div>
                      <div className="flex justify-between font-semibold pt-2 border-t">
                        <span>Total:</span>
                        <span>
                          ${appointmentType === "video" ? doctor.consultationFee - 20 : doctor.consultationFee}
                        </span>
                      </div>
                    </CardContent>
                  </Card>
                </div>

                <div className="flex justify-between">
                  <Button variant="outline" onClick={() => setStep(2)}>
                    Back
                  </Button>
                  <Button
                    onClick={handleBooking}
                    disabled={!patientInfo.name || !patientInfo.email || !patientInfo.phone}
                  >
                    Book Appointment
                  </Button>
                </div>
              </div>
            )}
          </div>
        )}
      </DialogContent>
    </Dialog>
  )
}
